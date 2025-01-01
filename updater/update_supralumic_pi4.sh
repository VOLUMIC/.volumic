#!/bin/bash

cd ~/klipper
make clean KCONFIG_CONFIG=~/printer_data/config/.volumic/updater/config.supralumic
make KCONFIG_CONFIG=~/printer_data/config/.volumic/updater/config.supralumic
make KCONFIG_CONFIG=~/printer_data/config/.volumic/updater/config.supralumic flash FLASH_DEVICE=/dev/serial/by-path/platform-fd500000.pcie-pci-0000:01:00.0-usb-0:1.2:1.0
