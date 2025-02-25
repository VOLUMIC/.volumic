#!/bin/bash

cd ~/klipper
make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic
make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic
make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic flash FLASH_DEVICE=/dev/serial/by-path/platform-fd500000.pcie-pci-0000:01:00.0-usb-0:1.2:1.0
