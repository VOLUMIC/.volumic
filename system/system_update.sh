#!/bin/bash

# update backport repository with archive (end of support on 2024)
sudo sed -i 's/deb.debian.org\/debian bullseye-backports/archive.debian.org\/debian bullseye-backports/' /etc/apt/sources.list

# Update system
sudo apt update
sudo apt upgrade -y

cd /home/Volumic/printer_data/config/.volumic/system/
sudo cp -f watermark.png /usr/share/plymouth/themes/armbian/
sudo plymouth-set-default-theme -R armbian
#sudo sed -i '/^sudo cp -f watermark.png \/usr\/share\/plymouth\/themes\/armbian\//s/^/#/' /home/Volumic/VyperOS/vyperos_update.sh
#sudo sed -i '/^sudo plymouth-set-default-theme -R armbian/s/^/#/' /home/Volumic/VyperOS/vyperos_update.sh
