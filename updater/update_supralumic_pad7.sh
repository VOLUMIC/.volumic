#!/bin/bash

cd ~/klipper
make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.supralumic
make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.supralumic
make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.supralumic flash FLASH_DEVICE=/dev/serial/by-path/platform-5200000.usb-usb-0:1.3:1.0
