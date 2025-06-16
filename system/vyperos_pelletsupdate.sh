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
	cp -f /home/Volumic/printer_data/config/.volumic/system/vyperos_pelletsupdate.sh /home/Volumic/VyperOS/vyperos_update.sh
	cp -f /home/Volumic/printer_data/config/.volumic/system/system_update.sh /home/Volumic/VyperOS
	sudo chmod 776 updater/*.sh
	sudo chmod 776 *.sh

	# Update USB Loader
	cd /home/Volumic/Moonraker-loader/
	git reset --hard
	git clean -fd
	git pull
	sudo ln -sf ~/Moonraker-loader/assets/89-moonraker-loader.rules /etc/udev/rules.d
	sudo ln -sf ~/Moonraker-loader/assets/*.sh /usr/local/sbin

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

	# Update klipper
	cd /home/Volumic/klipper
	git pull

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
	make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.supralumic
	make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.supralumic
	make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.supralumic flash FLASH_DEVICE=/dev/serial/by-path/platform-5200000.usb-usb-0:1.3:1.0

	# Force system update after boot
	cd /home/Volumic/VyperOS
	if [ -d "sys1" ]; then
		rmdir sys1
	fi

else	# no internet connexion

	echo "Local update"

	sudo service klipper stop

	# Update USB Loader
	sudo ln -sf ~/Moonraker-loader/assets/89-moonraker-loader.rules /etc/udev/rules.d
	sudo ln -sf ~/Moonraker-loader/assets/*.sh /usr/local/sbin

	# Update accelerometer MCU
	cd /home/Volumic/klipper
	make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
	make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
	sudo make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc flash FLASH_DEVICE=/dev/serial/by-path/platform-5200000.usb-usb-0:1.4:1.0

	# Update MCU
	cd /home/Volumic/klipper
	make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.supralumic
	make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.supralumic
	make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.supralumic flash FLASH_DEVICE=/dev/serial/by-path/platform-5200000.usb-usb-0:1.3:1.0

fi 

# Update Mainsail images
sudo cp -f /home/Volumic/printer_data/config/.volumic/system/img/icons/*.* /home/Volumic/mainsail/img/icons/
sudo cp -f /home/Volumic/printer_data/config/.volumic/system/img/themes/*.* /home/Volumic/mainsail/img/themes/
sudo cp -f /home/Volumic/printer_data/config/.volumic/system/img/*.* /home/Volumic/mainsail/img/

# Update configs
sudo cp -f /home/Volumic/printer_data/config/.volumic/system/KlipperScreen.conf /home/Volumic/printer_data/config
sudo cp -f /home/Volumic/printer_data/config/.volumic/system/mainsail_style.css /home/Volumic/printer_data/config/.theme/custom.css

#shutdown -h 0
reboot
