#!/bin/bash

sudo service klipper stop
cd ~/klipper
git pull
make clean KCONFIG_CONFIG=~/printer_data/config/.volumic/updater/config.ultralumic
make KCONFIG_CONFIG=~/printer_data/config/.volumic/updater/config.ultralumic
make KCONFIG_CONFIG=~/printer_data/config/.volumic/updater/config.ultralumic flash FLASH_DEVICE=/dev/serial/by-path/platform-fd500000.pcie-pci-0000:01:00.0-usb-0:1.2:1.0
sudo service klipper start
