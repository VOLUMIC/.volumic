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
	cp -f /home/Volumic/printer_data/config/.volumic/system/*.sh /home/Volumic/VyperOS
	cp -f /home/Volumic/printer_data/config/.volumic/system/KlipperScreen.conf /home/Volumic/printer_data/config/KlipperScreen.conf
	sudo chmod 776 updater/*.sh
	sudo chmod 776 *.sh
	sudo cp -f /home/Volumic/printer_data/config/.volumic/system/90-usb.rules /etc/udev/rules.d/90-usb.rules
	sudo cp /home/Volumic/printer_data/config/.volumic/system/vyper-usb /etc/sudoers.d/vyper-usb
	cd /home/Volumic
	if [ -d "Moonraker-loader" ]; then
		sudo mv /home/Volumic/Moonraker-loader /home/Volumic/Moonraker-loader.old
	fi

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

	# Update Obico
	cd /home/Volumic/moonraker-obico/
	git pull

	# Update accelerometer MCU
	cd /home/Volumic/klipper
	make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
	make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
	sudo make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc flash FLASH_DEVICE=/dev/serial/by-path/platform-xhci-hcd.4.auto-usb-0:1:1.0

	# Update MCU
	cd /home/Volumic/VyperOS
	if [ -d "SAM3X8E" ]; then
		cd /home/Volumic/klipper
		make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic flash FLASH_DEVICE=/dev/serial/by-path/platform-fd840000.usb-usb-0:1:1.0
	elif [ -d "STM32H723M8" ]; then
		cd /home/Volumic/klipper
		make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta flash FLASH_DEVICE=/dev/serial/by-path/platform-xhci-hcd.4.auto-usb-0:1.4:1.0
	else
		cd /home/Volumic/klipper
		make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.hyperlumic
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.hyperlumic
		cd /home/Volumic/klipper/lib/hidflash
		./hid-flash /home/Volumic/klipper/out/klipper.bin serial/by-path/platform-fd840000.usb-usb-0:1:1.0
		# make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.hyperlumic flash FLASH_DEVICE=/dev/serial/by-path/platform-fd840000.usb-usb-0:1:1.0
	fi

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
	sudo make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc flash FLASH_DEVICE=/dev/serial/by-path/platform-xhci-hcd.4.auto-usb-0:1:1.0

	# Update MCU
	cd /home/Volumic/VyperOS
	if [ -d "SAM3X8E" ]; then
		cd /home/Volumic/klipper
		make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic flash FLASH_DEVICE=/dev/serial/by-path/platform-fd840000.usb-usb-0:1:1.0
	elif [ -d "STM32H723M8" ]; then
		cd /home/Volumic/klipper
		make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta flash FLASH_DEVICE=/dev/serial/by-path/platform-xhci-hcd.4.auto-usb-0:1.4:1.0
	else
		cd /home/Volumic/klipper
		make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.hyperlumic
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.hyperlumic
		cd /home/Volumic/klipper/lib/hidflash
		./hid-flash /home/Volumic/klipper/out/klipper.bin serial/by-path/platform-fd840000.usb-usb-0:1:1.0
	fi

fi

# Update Mainsail images
sudo cp -f /home/Volumic/printer_data/config/.volumic/system/img/icons/*.* /home/Volumic/mainsail/img/icons/
sudo cp -f /home/Volumic/printer_data/config/.volumic/system/img/themes/*.* /home/Volumic/mainsail/img/themes/
sudo cp -f /home/Volumic/printer_data/config/.volumic/system/img/*.* /home/Volumic/mainsail/img/

# Update configs
sudo cp -f /home/Volumic/printer_data/config/.volumic/system/KlipperScreen.conf /home/Volumic/printer_data/config
sudo cp -f /home/Volumic/printer_data/config/.volumic/system/mainsail_style.css /home/Volumic/printer_data/config/.theme/custom.css

cd /home/Volumic/VyperOS
if [ -d "SAM3X8E" ]; then
	reboot
else
	#sudo systemctl stop KlipperScreen 2>/dev/null || true
	#sudo plymouth quit --retain-splash 2>/dev/null || true
	#sudo sh -c 'echo "" > /dev/tty1'
	#sudo sh -c 'echo "" > /dev/tty1'
	#sudo sh -c 'printf "\033[2J\033[H" > /dev/tty1'  # efface l ecran
	#sudo sh -c 'echo "" > /dev/tty1'
	#sudo sh -c 'echo "   MISE A JOUR INTERNET TERMINEE" > /dev/tty1'
	#sudo sh -c 'echo " " > /dev/tty1'
	#sudo sh -c 'echo "   Veuillez eteindre la machine electriquement" > /dev/tty1'
	#sudo sh -c 'echo "   puis rallumez-la pour finaliser la mise a jour..." > /dev/tty1'
	#sudo sh -c 'echo " " > /dev/tty1'
	#sudo sh -c 'echo " " > /dev/tty1'
	#sudo sh -c 'echo "   Selon la version precedente installee, il est possible que vous ayez a relancer une 2eme fois la mise a jour si tout les modules ne le sont pas du premier coup." > /dev/tty1'
	#sudo sh -c 'echo "" > /dev/tty1'
	sudo shutdown -h 0
fi
