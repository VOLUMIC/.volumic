#!/bin/bash

cd ~/klipper
make clean KCONFIG_CONFIG=/home/Volumic/printer_data/config/.volumic/updater/config.ultralumic
make KCONFIG_CONFIG=/home/Volumic/printer_data/config/.volumic/updater/config.ultralumic
make KCONFIG_CONFIG=/home/Volumic/printer_data/config/.volumic/updater/config.ultralumic flash FLASH_DEVICE=/dev/serial/by-path/platform-xhci-hcd.4.auto-usb-0:1.4:1.0
