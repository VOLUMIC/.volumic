#!/bin/bash

cd /home/Volumic/printer_data/config/.volumic/system/
sudo cp watermark.png /usr/share/plymouth/themes/armbian/
sudo plymouth-set-default-theme -R armbian
