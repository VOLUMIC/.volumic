#!/bin/bash

cd /home/Volumic/printer_data/config/.volumic/system/
sudo cp watermark.png /usr/share/plymouth/themes/armbian/
sudo plymouth-set-default-theme -R armbian
#sudo sed -i '/^sudo cp watermark.png \/usr\/share\/plymouth\/themes\/armbian\//s/^/#/' system.sh
#sudo sed -i '/^sudo plymouth-set-default-theme -R armbian/s/^/#/' system.sh
