#!/usr/bin/env python3
"""
Update the STM32 HID bootloader on an STM32H723 board over USB, from a Linux (Klipper) host.
No debug probe needed.

Sequence:
  1. Ask the running Klipper firmware to reboot into the bootloader (1200 baud, DTR low).
  2. Get the board into the ST ROM DFU bootloader:
       - bootloader 3.10 or later stays active and is sent the EnterDFU command
       - earlier bootloaders start Klipper again, which then enters ROM DFU by itself
  3. Write the new bootloader with dfu-util, read it back and compare, and only then start it.
  4. Wait for Klipper to come back.

Every step only talks to the one physical USB port the board is plugged in to.

Requires: python3 (3.7+), dfu-util. Run as root (sudo), ideally inside tmux/screen if working over SSH.

Usage:
  sudo python3 update_bootloader.py STM32_HIDBL.bin
  sudo python3 update_bootloader.py STM32_HIDBL.bin --serial /dev/serial/by-id/usb-Klipper_stm32h723xx_...
  sudo python3 update_bootloader.py STM32_HIDBL.bin --usb-port 1-1.2     (board already in a bootloader)

Exit codes:
  0  bootloader updated, Klipper is back
  1  nothing was changed (bad arguments, wrong image, board not found, cancelled)
  2  could not get the board into ROM DFU - nothing was written
  3  writing failed - board is still in ROM DFU, do not power it off, run the script again
  4  bootloader written and verified, but Klipper did not come back
"""

import argparse
import fcntl
import glob
import hashlib
import os
import shutil
import signal
import struct
import subprocess
import sys
import tempfile
import termios
import time

KLIPPER_MCU = "stm32h723"
HID_BL_ID = (0x1209, 0xBEBA)
ROM_DFU_ID = (0x0483, 0xDF11)

# First bootloader version (USB bcdDevice) that ignores unknown commands and knows EnterDFU.
# Earlier versions lock up (until power cycled) if sent a command they do not know, so must never be sent it.
ENTER_DFU_MIN_BCD = 0x0310

FLASH_BASE = 0x08000000
BOOTLOADER_MAX_SIZE = 0x20000
BOOTLOADER_MIN_SIZE = 0x2000
# The bootloader's initial stack pointer is the end of its RAM (see Variants/H723ZGTX/ldscript.ld)
BOOTLOADER_RAM = (0x24000000, 0x24050000)

# "BTLDCMD" signature, EnterDFU command (0x04), "DFU!" key
ENTER_DFU_PACKET = b"BTLDCMD" + bytes([0x04]) + b"DFU!"
HID_PACKET_SIZE = 64

ENTER_DFU_TIMEOUT = 45
OLD_BOOTLOADER_MAX_SECONDS = 12   # earlier bootloaders leave for the application ~5 s after reset
WRITE_ATTEMPTS = 3
DFU_UTIL_TIMEOUT = 120

EXIT_OK, EXIT_NOTHING_CHANGED, EXIT_NO_DFU, EXIT_WRITE_FAILED, EXIT_NO_KLIPPER = 0, 1, 2, 3, 4

NOTHING_WRITTEN = "Nothing has been written - the existing bootloader is unchanged."


def fail(code, *lines):
    print()
    for line in lines:
        print(line)
    sys.exit(code)


# ---------------------------------------------------------------------------------------------------------------
# USB port helpers. A "port" is the kernel's name for a physical USB port, e.g. "1-1.2".

def port_dir(port):
    return os.path.join("/sys/bus/usb/devices", port)


def read_attr(port, name):
    try:
        with open(os.path.join(port_dir(port), name)) as f:
            return f.read().strip()
    except OSError:
        return None


def port_ids(port):
    """(vid, pid) of the device currently on the port, or None"""
    vid, pid = read_attr(port, "idVendor"), read_attr(port, "idProduct")
    try:
        return (int(vid, 16), int(pid, 16))
    except (TypeError, ValueError):
        return None


def port_tty(port):
    ttys = glob.glob(os.path.join(port_dir(port), port + ":*", "tty", "*"))
    return "/dev/" + os.path.basename(ttys[0]) if ttys else None


def port_hidraw(port):
    nodes = glob.glob(os.path.join(port_dir(port), port + ":*", "*", "hidraw", "hidraw*"))
    return "/dev/" + os.path.basename(nodes[0]) if nodes else None


def port_of_tty(tty_path):
    """USB port that a serial device (any /dev path or symlink to it) is attached to"""
    name = os.path.basename(os.path.realpath(tty_path))
    dev = os.path.realpath(os.path.join("/sys/class/tty", name, "device"))   # .../1-1.2/1-1.2:1.0
    port = os.path.basename(os.path.dirname(dev))
    return port if port_ids(port) else None


def ports_with(*wanted_ids):
    found = []
    for dev in glob.glob("/sys/bus/usb/devices/*"):
        port = os.path.basename(dev)
        if ":" not in port and port_ids(port) in wanted_ids:
            found.append(port)
    return sorted(found)


def describe(port):
    ids = port_ids(port)
    if not ids:
        return "nothing"
    return "%04x:%04x %s %s" % (ids[0], ids[1], read_attr(port, "manufacturer") or "",
                                read_attr(port, "product") or "")


# ---------------------------------------------------------------------------------------------------------------

def check_bootloader_image(path, sha256):
    try:
        with open(path, "rb") as f:
            image = f.read()
    except OSError as e:
        fail(EXIT_NOTHING_CHANGED, "Error: cannot read %s: %s" % (path, e.strerror))

    if not BOOTLOADER_MIN_SIZE <= len(image) <= BOOTLOADER_MAX_SIZE:
        fail(EXIT_NOTHING_CHANGED, "Error: %s is %d bytes - not a plausible bootloader image "
             "(truncated download?)." % (path, len(image)))

    stack, reset = struct.unpack("<II", image[:8])
    stack_ok = stack % 4 == 0 and BOOTLOADER_RAM[0] < stack <= BOOTLOADER_RAM[1]
    reset_ok = reset % 2 == 1 and FLASH_BASE <= reset < FLASH_BASE + len(image)
    if not (stack_ok and reset_ok):
        fail(EXIT_NOTHING_CHANGED,
             "Error: %s is not an STM32H723 bootloader image (stack 0x%08X, reset 0x%08X)." % (path, stack, reset),
             "It may be a bootloader for a different board, or an application. Refusing to write it.")

    digest = hashlib.sha256(image).hexdigest()
    if sha256 and sha256.lower() != digest:
        fail(EXIT_NOTHING_CHANGED, "Error: SHA-256 mismatch - the file is corrupt or not the expected release.",
             "  expected %s" % sha256.lower(), "  actual   %s" % digest)
    return image, digest


def find_board(args):
    """Work out which physical USB port the board is on. Returns (port, klipper by-id path or None)."""
    if args.usb_port:
        if not port_ids(args.usb_port):
            fail(EXIT_NOTHING_CHANGED, "Error: no USB device on port %s." % args.usb_port)
        return args.usb_port, None

    serial = args.serial
    if not serial:
        candidates = sorted(glob.glob("/dev/serial/by-id/usb-Klipper_%s*" % KLIPPER_MCU))
        if len(candidates) == 1:
            serial = candidates[0]
        elif len(candidates) > 1:
            fail(EXIT_NOTHING_CHANGED, "Error: more than one Klipper %s board found, choose one with --serial:"
                 % KLIPPER_MCU, *["  " + c for c in candidates])

    if serial:
        if not os.path.exists(serial):
            fail(EXIT_NOTHING_CHANGED, "Error: %s does not exist." % serial)
        port = port_of_tty(serial)
        if not port:
            fail(EXIT_NOTHING_CHANGED, "Error: %s is not a USB serial port." % serial)
        product = (read_attr(port, "product") or "").lower()
        if KLIPPER_MCU not in product and not args.force:
            fail(EXIT_NOTHING_CHANGED,
                 "Error: %s is '%s', not a Klipper %s board." % (serial, describe(port), KLIPPER_MCU),
                 "This bootloader must only be written to an STM32H723. (--force overrides this check.)")
        return port, serial if "/by-id/" in serial else None

    # No Klipper board: is exactly one board already sitting in a bootloader?
    in_bootloader = ports_with(HID_BL_ID, ROM_DFU_ID)
    if len(in_bootloader) == 1:
        return in_bootloader[0], None
    if in_bootloader:
        fail(EXIT_NOTHING_CHANGED, "Error: several devices are in a bootloader, choose one with --usb-port:",
             *["  %s  (%s)" % (p, describe(p)) for p in in_bootloader])
    fail(EXIT_NOTHING_CHANGED, "Error: no Klipper %s board found. Is it connected and running Klipper?" % KLIPPER_MCU,
         "If it is, specify its serial port with --serial.")


def request_bootloader(tty):
    """Klipper treats 1200 baud with DTR low as a request to enter the bootloader."""
    try:
        fd = os.open(tty, os.O_RDWR | os.O_NOCTTY | os.O_NONBLOCK)
    except OSError as e:
        print("  could not open %s: %s" % (tty, e.strerror))
        return
    try:
        fcntl.ioctl(fd, termios.TIOCMBIC, struct.pack("I", termios.TIOCM_DTR))
        attrs = termios.tcgetattr(fd)
        attrs[4] = attrs[5] = termios.B1200
        termios.tcsetattr(fd, termios.TCSANOW, attrs)
        time.sleep(0.2)
    except (OSError, termios.error):
        pass  # the device resets as soon as it sees the request, so the port may vanish under us
    finally:
        try:
            os.close(fd)
        except OSError:
            pass


def send_enter_dfu(port):
    hidraw = None
    for _ in range(20):
        hidraw = port_hidraw(port)
        if hidraw:
            break
        time.sleep(0.1)
    if not hidraw:
        print("  no hidraw device for the bootloader yet")
        return False
    packet = bytes([0x00]) + ENTER_DFU_PACKET.ljust(HID_PACKET_SIZE, b"\x00")  # leading byte is the report ID
    try:
        with open(hidraw, "wb", buffering=0) as f:
            f.write(packet)
    except OSError:
        pass  # the bootloader resets on receipt, so the write can fail even though the command was received
    return True


def enter_rom_dfu(port):
    """Drive the board on `port` into the ROM DFU bootloader, from whatever state it is in."""
    deadline = time.monotonic() + ENTER_DFU_TIMEOUT
    requests_sent = 0
    enter_dfu_sent_at = None
    old_bootloader_since = None
    last_state = None

    while time.monotonic() < deadline:
        ids = port_ids(port)
        state = describe(port)
        if state != last_state:
            print("  board: %s" % state)
            last_state = state

        if ids == ROM_DFU_ID:
            return

        if ids == HID_BL_ID:
            bcd = int(read_attr(port, "bcdDevice") or "0", 16)
            if bcd >= ENTER_DFU_MIN_BCD:
                if enter_dfu_sent_at is None or time.monotonic() - enter_dfu_sent_at > 10:
                    print("  bootloader %x.%02x: sending EnterDFU" % (bcd >> 8, bcd & 0xFF))
                    if send_enter_dfu(port):
                        enter_dfu_sent_at = time.monotonic()
            else:
                # Earlier bootloader: never send it EnterDFU. Left alone it starts Klipper within ~5 s, which
                # (if Klipper requested the bootloader) then enters ROM DFU by itself.
                old_bootloader_since = old_bootloader_since or time.monotonic()
                if time.monotonic() - old_bootloader_since > OLD_BOOTLOADER_MAX_SECONDS:
                    fail(EXIT_NO_DFU,
                         "Error: the board is being held in an earlier bootloader version, which cannot be asked "
                         "to enter ROM DFU.", NOTHING_WRITTEN,
                         "Power-cycle the board WITHOUT holding its boot button, wait for Klipper to start, and "
                         "run this script again.")
        else:
            old_bootloader_since = None
            tty = port_tty(port)
            if tty and requests_sent < 3:
                time.sleep(1.0)  # let the serial port settle (ModemManager, klippy) before using it
                print("  requesting bootloader via %s" % tty)
                request_bootloader(tty)
                requests_sent += 1
                time.sleep(1.0)

        time.sleep(0.2)

    fail(EXIT_NO_DFU, "Error: could not get the board into the ROM DFU bootloader (board is now: %s)."
         % describe(port), NOTHING_WRITTEN, "Power-cycle the board to return it to normal operation.")


def dfu_util(port, *args):
    """Run dfu-util against the ROM DFU device on `port` only. Returns its combined output."""
    cmd = ["dfu-util", "-d", "%04x:%04x" % ROM_DFU_ID, "-p", port, "-a", "0"] + list(args)
    try:
        # Own session: a Ctrl-C or SSH hang-up aimed at this script must not kill dfu-util mid-write
        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=DFU_UTIL_TIMEOUT,
                                start_new_session=True)
        return result.stdout.decode("utf-8", errors="replace")
    except subprocess.TimeoutExpired:
        return "dfu-util timed out"


def write_and_verify(port, path, image):
    """Write the image to the start of flash and read it back. The board stays in ROM DFU throughout."""
    for attempt in range(1, WRITE_ATTEMPTS + 1):
        if attempt > 1:
            print("  retrying (attempt %d of %d)" % (attempt, WRITE_ATTEMPTS))
            time.sleep(2)
        if port_ids(port) != ROM_DFU_ID:
            print("  board is no longer in ROM DFU (now: %s)" % describe(port))
            continue

        output = dfu_util(port, "-s", "0x%08X" % FLASH_BASE, "-D", path)
        if "File downloaded successfully" not in output:
            print("  write failed:\n    " + "\n    ".join(output.strip().splitlines()[-4:]))
            continue

        readback = os.path.join(tempfile.mkdtemp(prefix="hidbl-"), "readback.bin")  # dfu-util will not overwrite
        output = dfu_util(port, "-s", "0x%08X:%d" % (FLASH_BASE, len(image)), "-U", readback)
        try:
            with open(readback, "rb") as f:
                verified = f.read() == image
        except OSError:
            verified = False
        shutil.rmtree(os.path.dirname(readback), ignore_errors=True)
        if verified:
            print("  written and verified (%d bytes)" % len(image))
            return True
        print("  read-back does not match what was written")
    return False


def leave_dfu(port):
    """Start the newly written bootloader. dfu-util only acts on ':leave' as part of a transfer, so read a few
    bytes. It reports a get_status error afterwards because the device has already gone - that is expected."""
    scratch = os.path.join(tempfile.mkdtemp(prefix="hidbl-"), "leave.bin")
    dfu_util(port, "-s", "0x%08X:16:leave" % FLASH_BASE, "-U", scratch)
    shutil.rmtree(os.path.dirname(scratch), ignore_errors=True)


def main():
    parser = argparse.ArgumentParser(description="Update the STM32 HID bootloader on an STM32H723 board over USB")
    parser.add_argument("bootloader_bin", help="new bootloader image (.bin)")
    parser.add_argument("--serial", help="the board's Klipper serial port (default: auto-detect)")
    parser.add_argument("--usb-port", help="USB port of a board that is already in a bootloader, e.g. 1-1.2")
    parser.add_argument("--sha256", help="expected SHA-256 of the bootloader image")
    parser.add_argument("--yes", action="store_true", help="do not ask for confirmation")
    parser.add_argument("--force", action="store_true", help="skip the check that the board is a Klipper " + KLIPPER_MCU)
    args = parser.parse_args()

    sys.stdout.reconfigure(line_buffering=True)  # keep progress visible when output is piped or logged

    if os.geteuid() != 0:
        fail(EXIT_NOTHING_CHANGED, "Error: please run as root (sudo).")
    if not shutil.which("dfu-util"):
        fail(EXIT_NOTHING_CHANGED, "Error: dfu-util not found, install it with: sudo apt-get install dfu-util")

    image, digest = check_bootloader_image(args.bootloader_bin, args.sha256)
    port, klipper_serial = find_board(args)

    print("Bootloader image : %s (%d bytes)" % (args.bootloader_bin, len(image)))
    print("         SHA-256 : %s" % digest)
    print("Board            : USB port %s - %s" % (port, describe(port)))
    print()
    #print("This RESETS the board, so make sure no print is running. Once writing starts the board must not be")
    #print("powered off or unplugged until it has finished (about 20 seconds).")
    #if not args.yes:
    #    try:
    #        answer = input("Update the bootloader on this board? [y/N] ")
    #    except EOFError:
    #        answer = ""
    #    if answer.strip().lower() not in ("y", "yes"):
    #        fail(EXIT_NOTHING_CHANGED, "Cancelled. " + NOTHING_WRITTEN)

    print("Entering ROM DFU bootloader")
    enter_rom_dfu(port)
    time.sleep(1)  # let the DFU interface settle

    print("Writing bootloader - do NOT power off or unplug the board")
    # From here until the write has been verified, ignore Ctrl-C / hang-up / terminate
    previous = {s: signal.signal(s, signal.SIG_IGN) for s in (signal.SIGINT, signal.SIGHUP, signal.SIGTERM)}
    written = write_and_verify(port, args.bootloader_bin, image)
    if written:
        leave_dfu(port)
    for s, handler in previous.items():
        signal.signal(s, handler)

    if not written:
        still_dfu = port_ids(port) == ROM_DFU_ID
        fail(EXIT_WRITE_FAILED, "Error: the bootloader could NOT be written and verified.",
             "The board %s." % ("is still in the ROM DFU bootloader" if still_dfu else "is now: " + describe(port)),
             "Do NOT power off or unplug the board - it may not have a working bootloader. Run this script again:",
             "  sudo python3 %s %s --usb-port %s" % (sys.argv[0], args.bootloader_bin, port),
             "If it keeps failing, leave the board powered and contact support.")

    print("Waiting for Klipper to restart")
    deadline = time.monotonic() + 40
    while time.monotonic() < deadline:
        back = os.path.exists(klipper_serial) if klipper_serial else bool(port_tty(port))
        if back and port_ids(port) not in (HID_BL_ID, ROM_DFU_ID):
            print("Done - bootloader updated. Use FIRMWARE_RESTART (or restart the Klipper service) to reconnect.")
            sys.exit(EXIT_OK)
        time.sleep(0.5)

    fail(EXIT_NO_KLIPPER, "The new bootloader was written and verified, but Klipper has not come back "
         "(board is now: %s)." % describe(port),
         "If the board shows as the HID bootloader it has no valid application - flash Klipper as usual.",
         "Otherwise power-cycle the board.")


if __name__ == "__main__":
    main()
