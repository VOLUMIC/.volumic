#!/bin/bash

# Make updater scripts executable
cd /home/Volumic/printer_data/config/.volumic/updater/
sudo chmod +x *.sh

# Update Mainsail images
sudo cp /home/Volumic/printer_data/config/.volumic/system/img/icons/*.* /home/Volumic/mainsail/img/icons/
sudo cp /home/Volumic/printer_data/config/.volumic/system/img/themes/*.* /home/Volumic/mainsail/img/themes/
sudo cp /home/Volumic/printer_data/config/.volumic/system/img/*.* /home/Volumic/mainsail/img/

# Reinitialize Volumic boot logo (after a system update for exemple)
cd /home/Volumic/printer_data/config/.volumic/system/
#sudo cp bootsplash.armbian /usr/lib/firmware/bootsplash.armbian
#sudo update-initramfs -v -u
sudo sed -i '/^sudo cp bootsplash.armbian \/usr\/lib\/firmware\/bootsplash.armbian/s/^/#/' system.sh
sudo sed -i '/^sudo update-initramfs -v -u/s/^/#/' system.sh
