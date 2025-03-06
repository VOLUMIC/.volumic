#!/bin/bash

# Update system
sudo apt update && sudo apt upgrade -y

cd /home/Volumic/printer_data/config/.volumic/system/
sudo cp bootsplash.armbian /usr/lib/firmware/bootsplash.armbian
sudo update-initramfs -v -u
#sudo sed -i '/^sudo cp bootsplash.armbian \/usr\/lib\/firmware\/bootsplash.armbian/s/^/#/' system.sh
#sudo sed -i '/^sudo update-initramfs -v -u/s/^/#/' system.sh