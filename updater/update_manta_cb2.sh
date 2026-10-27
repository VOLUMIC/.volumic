#!/bin/bash

cd /home/Volumic/klipper
make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta
make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta
# Flash par la copie VyperOS (repli sur la copie du depot, lancee par bash : pas besoin du droit d'execution)
HFS=/home/Volumic/VyperOS/hidflash_safe.sh; [ -f "$HFS" ] || HFS=/home/Volumic/printer_data/config/.volumic/system/hidflash_safe.sh
bash "$HFS" /home/Volumic/klipper/out/klipper.bin serial/by-path/platform-xhci-hcd.4.auto-usb-0:1.4:1.0
