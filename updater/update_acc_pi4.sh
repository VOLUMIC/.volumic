#!/bin/bash

cd ~/klipper
make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc flash FLASH_DEVICE=/dev/serial/by-path/platform-fd500000.pcie-pci-0000:01:00.0-usb-0:1.3:1.0
