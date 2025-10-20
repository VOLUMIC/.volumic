#!/bin/bash

# update backport repository with archive (end of support on 2024)
#sudo sed -i 's/deb.debian.org\/debian bullseye-backports/archive.debian.org\/debian bullseye-backports/' /etc/apt/sources.list

cd /home/Volumic/printer_data/config/.volumic/system/
# update repository list
sudo cp -f sources.list /etc/apt/

# Update system
sudo apt update
sudo apt upgrade -y

sudo cp -f watermark.png /usr/share/plymouth/themes/armbian/
sudo plymouth-set-default-theme -R armbian
