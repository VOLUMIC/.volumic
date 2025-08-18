#!/bin/bash

# update backport repository with archive (end of support on 2024)
sudo sed -i 's/deb.debian.org\/debian bullseye-backports/archive.debian.org\/debian bullseye-backports/' /etc/apt/sources.list

# Update system
sudo apt update
sudo apt upgrade -y

cd /home/Volumic/printer_data/config/.volumic/system/
sudo cp bootsplash.armbian /usr/lib/firmware/bootsplash.armbian
sudo update-initramfs -v -u
