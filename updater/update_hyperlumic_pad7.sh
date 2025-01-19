#!/bin/bash

cd ~/klipper
make clean KCONFIG_CONFIG=/home/Volumic/printer_data/config/.volumic/updater/config.hyperlumic
make KCONFIG_CONFIG=/home/Volumic/printer_data/config/.volumic/updater/config.hyperlumic
make KCONFIG_CONFIG=/home/Volumic/printer_data/config/.volumic/updater/config.hyperlumic flash FLASH_DEVICE=/dev/serial/by-path/platform-5200000.usb-usb-0:1.3:1.0
