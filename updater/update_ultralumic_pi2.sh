#!/bin/bash

cd ~/klipper
make clean KCONFIG_CONFIG=~/printer_data/config/.volumic/updater/config.ultralumic
make KCONFIG_CONFIG=~/printer_data/config/.volumic/updater/config.ultralumic
make KCONFIG_CONFIG=~/printer_data/config/.volumic/updater/config.ultralumic flash FLASH_DEVICE=/dev/serial/by-path/platform-fd840000.usb-usb-0:1:1.0
