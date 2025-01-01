#!/bin/bash

cd ~/klipper
make clean KCONFIG_CONFIG=~/printer_data/config/.volumic/updater/config.manta
make KCONFIG_CONFIG=~/printer_data/config/.volumic/updater/config.manta
make KCONFIG_CONFIG=~/printer_data/config/.volumic/updater/config.manta flash FLASH_DEVICE=/dev/serial/by-path/platform-5200000.usb-usb-0:1.4:1.0
