#!/bin/bash

cd ~/klipper
make clean KCONFIG_CONFIG=~/printer_data/config/.volumic/updater/config.acc
make KCONFIG_CONFIG=~/printer_data/config/.volumic/updater/config.acc
make KCONFIG_CONFIG=~/printer_data/config/.volumic/updater/config.acc flash FLASH_DEVICE=/dev/serial/by-path/platform-5200000.usb-usb-0:1.1:1.0
