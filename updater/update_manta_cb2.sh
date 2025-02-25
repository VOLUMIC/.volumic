#!/bin/bash

cd ~/klipper
make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta
make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta
make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta flash FLASH_DEVICE=/dev/serial/by-path/platform-xhci-hcd.4.auto-usb-0:1.4:1.0
