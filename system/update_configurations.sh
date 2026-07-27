#!/bin/bash

ping -q -c 2 -W 3 8.8.8.8 >/dev/null 2>&1	# test if internet is connected
if [ $? -eq 0 ]; then	# internet connected

	sudo service klipper stop

	# Update configurations
	cd /home/Volumic/printer_data/config/.volumic
	git reset --hard
	git clean -fd
	git pull
	sudo cp /home/Volumic/printer_data/config/.volumic/system/vyper-usb /etc/sudoers.d/vyper-usb
	sudo cp -f /home/Volumic/printer_data/config/.volumic/system/90-usb.rules /etc/udev/rules.d/90-usb.rules
	cp -u -f /home/Volumic/printer_data/config/.volumic/updater/*.* /home/Volumic/VyperOS/updater
	cp -f /home/Volumic/printer_data/config/.volumic/system/KlipperScreen.conf /home/Volumic/printer_data/config/KlipperScreen.conf
	sudo chmod 776 /home/Volumic/VyperOS/updater/*.sh
	sudo chmod 776 /home/Volumic/VyperOS/*.sh
	cd /home/Volumic
	if [ -d "Moonraker-loader" ]; then
		mv /home/Volumic/Moonraker-loader /home/Volumic/Moonraker-loader.old
	fi

	sudo service klipper start
fi
