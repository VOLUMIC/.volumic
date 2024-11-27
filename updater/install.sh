#!/bin/bash

cd ~/printer_data/config/.volumic/updater
chmod +x *.sh
cd ~/klipper
make clean KCONFIG_CONFIG=~/printer_data/config/.volumic/updater/config.ultralumic
make KCONFIG_CONFIG=~/printer_data/config/.volumic/updater/config.ultralumic
make KCONFIG_CONFIG=~/printer_data/config/.volumic/updater/config.ultralumic flash FLASH_DEVICE=/dev/serial/by-path/platform-5200000.usb-usb-0:1.3:1.0
