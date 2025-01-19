#!/bin/bash

sudo cp /home/Volumic/printer_data/config/.volumic/system/watermark.png /usr/share/plymouth/themes/armbian/
sudo plymouth-set-default-theme -R armbian
cd /home/Volumic/printer_data/config/.volumic/system/
sudo sed -i '/^.\/initlogo.sh/s/^/#/' /home/Volumic/printer_data/config/.volumic/system/system.sh
