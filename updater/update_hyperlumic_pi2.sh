#!/bin/bash

# prérequis
# 1) hid-flash compilé
#cd ~/klipper/lib/hidflash
#make
# 2) autorisation udev pour hidflash
#cd /etc/udev/rules.d/
#sudo nano 99-stm32_hid_bl.rules
# et copier cela dans le fichier, puis rebooter :
# STM32_HID_bootloader
#ATTRS{idProduct}=="beba", ATTRS{idVendor}=="1209", MODE:="666" 


cd ~/klipper
make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.hyperlumic
make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.hyperlumic
# Flash par la copie VyperOS (repli sur la copie du depot, lancee par bash : pas besoin du droit d'execution)
HFS=/home/Volumic/VyperOS/hidflash_safe.sh; [ -f "$HFS" ] || HFS=/home/Volumic/printer_data/config/.volumic/system/hidflash_safe.sh
bash "$HFS" /home/Volumic/klipper/out/klipper.bin serial/by-path/platform-fd840000.usb-usb-0:1:1.0
