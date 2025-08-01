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
	cp -f /home/Volumic/printer_data/config/.volumic/system/vyperos_s2update.sh /home/Volumic/VyperOS/vyperos_update.sh
	cp -f /home/Volumic/printer_data/config/.volumic/system/systems2_update.sh /home/Volumic/VyperOS
	sudo chmod 776 updater/*.sh
	sudo chmod 776 *.sh

	# Update klipper
	cd /home/Volumic/klipper
	git pull

	# Update KlipperScreen
	cd /home/Volumic/KlipperScreen
	git reset --hard
	git clean -fd
	git pull

	# Update mainsail
	cd /home/Volumic/mainsail
	rm -R -f ./*
	rm .version
	wget -q -O mainsail.zip https://github.com/mainsail-crew/mainsail/releases/latest/download/mainsail.zip && unzip mainsail.zip && rm mainsail.zip

	# Update Moonraker
	cd /home/Volumic/moonraker
	git pull

	# Update accelerometer MCU
	cd /home/Volumic/klipper
	make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
	make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
	sudo make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc flash FLASH_DEVICE=/dev/serial/by-path/platform-5200000.usb-usb-0:1.4:1.0

	# Update MCU
	cd /home/Volumic/klipper
	make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic
	make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic
	make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic flash FLASH_DEVICE=/dev/serial/by-path/platform-5200000.usb-usb-0:1.3:1.0

	# Force system update after boot
	cd /home/Volumic/VyperOS
	if [ -d "sys1" ]; then
		rmdir sys1
	fi


else	# no internet connexion

	echo "Local update"

	sudo service klipper stop

	# Update accelerometer MCU
	cd /home/Volumic/klipper
	make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
	make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
	sudo make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc flash FLASH_DEVICE=/dev/serial/by-path/platform-5200000.usb-usb-0:1.4:1.0

	# Update MCU
	cd /home/Volumic/klipper
	make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic
	make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic
	make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic flash FLASH_DEVICE=/dev/serial/by-path/platform-5200000.usb-usb-0:1.3:1.0

fi 

#shutdown -h 0
reboot
