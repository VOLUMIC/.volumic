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
#sudo cp watermark.png /usr/share/plymouth/themes/armbian/
#sudo plymouth-set-default-theme -R armbian
sudo sed -i '/^sudo cp watermark.png \/usr\/share\/plymouth\/themes\/armbian\//s/^/#/' system.sh
sudo sed -i '/^sudo plymouth-set-default-theme -R armbian/s/^/#/' system.sh
