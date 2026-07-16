#!/bin/bash

ping -q -c 2 www.google.fr >/dev/null 2>&1	# test if internet is connected

if [ $? -eq 0 ]; then	# internet connected

	echo "Internet update"
	sudo service klipper stop

	# Update configurations
	cd /home/Volumic/printer_data/config/.volumic
	git reset --hard
	git clean -fd
	git pull
	cd /home/Volumic/VyperOS
	cp -u -f /home/Volumic/printer_data/config/.volumic/updater/*.* updater
	cp -f /home/Volumic/printer_data/config/.volumic/system/vyperos_update.sh /home/Volumic/VyperOS
	cp -f /home/Volumic/printer_data/config/.volumic/system/system_update.sh /home/Volumic/VyperOS
	cp -f /home/Volumic/printer_data/config/.volumic/system/vyperos_update_software.sh /home/Volumic/VyperOS
	cp -f /home/Volumic/printer_data/config/.volumic/system/copyusb.sh /home/Volumic/VyperOS
	cp -f /home/Volumic/printer_data/config/.volumic/system/unmountusb.sh /home/Volumic/VyperOS/unmountusb.sh
	cp -f /home/Volumic/printer_data/config/.volumic/system/mountusb.sh /home/Volumic/VyperOS/mountusb.sh
	cp -f /home/Volumic/printer_data/config/.volumic/system/resetnetwork.sh /home/Volumic/VyperOS/resetnetwork.sh
	cp -f /home/Volumic/printer_data/config/.volumic/system/KlipperScreen.conf /home/Volumic/printer_data/config/KlipperScreen.conf
	sudo cp -f /home/Volumic/printer_data/config/.volumic/system/90-usb.rules /etc/udev/rules.d/90-usb.rules
	sudo cp /home/Volumic/printer_data/config/.volumic/system/vyper-usb /etc/sudoers.d/vyper-usb
	sudo chmod 776 updater/*.sh
	sudo chmod 776 *.sh

fi

sudo bash /home/Volumic/VyperOS/vyperos_update_software.sh > /home/Volumic/VyperOS/softwareupdate.log 2>&1