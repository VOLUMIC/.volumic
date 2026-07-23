#!/bin/bash

cd /home/Volumic/printer_data/config/.volumic/system/
# update repository list
sudo cp -f /home/Volumic/printer_data/config/.volumic/system/sources.list /etc/apt/

# update sudo rights
sudo cp /home/Volumic/printer_data/config/.volumic/system/vyper-usb /etc/sudoers.d/vyper-usb
#echo "Volumic ALL=(ALL) NOPASSWD: /bin/bash /home/Volumic/VyperOS/resetnetwork.sh" | sudo tee /etc/sudoers.d/vyper-resetnetwork > /dev/null
sudo chmod 440 /etc/sudoers.d/vyper-usb

# Update system
sudo apt update
sudo apt upgrade -y

sudo cp -f /home/Volumic/printer_data/config/.volumic/system/watermark.png /usr/share/plymouth/themes/armbian/
sudo plymouth-set-default-theme -R armbian
