#!/bin/bash

cd /home/Volumic/klipper
make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta
make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta
cd /home/Volumic/klipper/lib/hidflash
./hid-flash /home/Volumic/klipper/out/klipper.bin serial/by-path/platform-xhci-hcd.4.auto-usb-0:1.4:1.0