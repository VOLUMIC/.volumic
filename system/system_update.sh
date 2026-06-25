#!/bin/bash

cd /home/Volumic/printer_data/config/.volumic/system/
# update repository list
sudo cp -f sources.list /etc/apt/

# update sudo rights
sudo cp /home/Volumic/printer_data/config/.volumic/system/vyper-usb /etc/sudoers.d/vyper-usb

# misc tasks
sudo mv Moonraker-loader Moonraker-loader.old
cp -f /home/Volumic/printer_data/config/.volumic/system/KlipperScreen.conf /home/Volumic/printer_data/config/KlipperScreen.conf

# Update system
sudo apt update
sudo apt upgrade -y

sudo cp -f watermark.png /usr/share/plymouth/themes/armbian/
sudo plymouth-set-default-theme -R armbian
