#!/bin/bash

cd ~/klipper
make clean KCONFIG_CONFIG=/home/Volumic/printer_data/config/.volumic/updater/config.supralumic
make KCONFIG_CONFIG=/home/Volumic/printer_data/config/.volumic/updater/config.supralumic
make KCONFIG_CONFIG=/home/Volumic/printer_data/config/.volumic/updater/config.supralumic flash FLASH_DEVICE=/dev/serial/by-path/platform-fd840000.usb-usb-0:1:1.0
