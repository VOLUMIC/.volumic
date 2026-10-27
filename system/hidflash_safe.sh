#!/bin/bash
# Flash securise d'une carte STM32H723 par le bootloader HID (Hyperlumic / Manta)
# usage : hidflash_safe.sh <firmware.bin> <serial/by-path/...>
# Ne flashe que si le firmware vient d'etre compile et si hid-flash est disponible.
BIN="$1"
DEV="$2"
HF=/home/Volumic/klipper/lib/hidflash

if [ -z "$BIN" ] || [ -z "$DEV" ]; then
	echo "hidflash_safe : usage : hidflash_safe.sh <firmware.bin> <serial/by-path/...>"
	exit 2
fi
# 1) firmware present et non vide (make clean l'efface, il n'existe que si la compilation a reussi)
if [ ! -s "$BIN" ]; then
	echo "hidflash_safe : firmware absent ou vide ($BIN), compilation echouee ? Flash annule."
	exit 1
fi
# 2) outil hid-flash present, sinon on le compile
if [ ! -x "$HF/hid-flash" ]; then
	echo "hidflash_safe : hid-flash absent, compilation..."
	if ! ( cd "$HF" && make ); then
		echo "hidflash_safe : compilation de hid-flash impossible. Flash annule."
		exit 1
	fi
fi
# 3) carte : simple avertissement (une carte deja en mode bootloader n'a plus de port serie)
if [ ! -e "/dev/$DEV" ]; then
	echo "hidflash_safe : port /dev/$DEV absent, tentative de flash directe par le bootloader HID"
fi
# 4) flash
cd "$HF" || exit 1
./hid-flash "$BIN" "$DEV"
RC=$?
if [ $RC -eq 0 ]; then
	echo "hidflash_safe : flash OK"
else
	echo "hidflash_safe : ECHEC du flash (code $RC)"
fi
exit $RC
