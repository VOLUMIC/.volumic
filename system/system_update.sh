#!/bin/bash

cd /home/Volumic/printer_data/config/.volumic/system/
# update repository list
sudo cp -f sources.list /etc/apt/

# update sudo rights
sudo cp /home/Volumic/printer_data/config/.volumic/system/vyper-usb /etc/sudoers.d/vyper-usb
#echo "Volumic ALL=(ALL) NOPASSWD: /bin/bash /home/Volumic/VyperOS/resetnetwork.sh" | sudo tee /etc/sudoers.d/vyper-resetnetwork > /dev/null
sudo chmod 440 /etc/sudoers.d/vyper-usb

# Update system
sudo apt update
sudo apt upgrade -y

sudo cp -f /home/Volumic/printer_data/config/.volumic/system/watermark.png /usr/share/plymouth/themes/armbian/
sudo plymouth-set-default-theme -R armbian

cd /home/Volumic/VyperOS
cp -u -f /home/Volumic/printer_data/config/.volumic/updater/*.* updater
cp -f /home/Volumic/printer_data/config/.volumic/system/*.sh /home/Volumic/VyperOS
cp -f /home/Volumic/printer_data/config/.volumic/system/KlipperScreen.conf /home/Volumic/printer_data/config/KlipperScreen.conf
sudo chmod 776 updater/*.sh
sudo chmod 776 *.sh
sudo cp -f /home/Volumic/printer_data/config/.volumic/system/90-usb.rules /etc/udev/rules.d/90-usb.rules
sudo cp /home/Volumic/printer_data/config/.volumic/system/vyper-usb /etc/sudoers.d/vyper-usb
cd /home/Volumic/
if [ -d "Moonraker-loader" ]; then
	sudo mv /home/Volumic/Moonraker-loader /home/Volumic/Moonraker-loader.old
fi
