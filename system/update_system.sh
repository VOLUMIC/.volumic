#!/bin/bash

ping -q -c 2 www.google.fr >/dev/null 2>&1	# test if internet is connected
if [ $? -eq 0 ]; then	# internet connected

	cd /home/Volumic/printer_data/config/.volumic/system/
	# update repository list
	sudo cp -f /home/Volumic/printer_data/config/.volumic/system/sources.list /etc/apt/

	# update sudo rights
	sudo cp /home/Volumic/printer_data/config/.volumic/system/vyper-usb /etc/sudoers.d/vyper-usb
	sudo chmod 440 /etc/sudoers.d/vyper-usb

	# Update system
	sudo apt update
	sudo apt upgrade -y

	sudo cp -f /home/Volumic/printer_data/config/.volumic/system/watermark.png /usr/share/plymouth/themes/armbian/
	sudo plymouth-set-default-theme -R armbian

	sleep 3
	reboot

fi
