#!/bin/bash
{

ping -q -c 2 -W 3 8.8.8.8 >/dev/null 2>&1	# test if internet is connected
if [ $? -eq 0 ]; then	# internet connected

	# Force system update after boot
	cd /home/Volumic/VyperOS
	if [ -d "sys1" ]; then
		rmdir sys1
	fi

	echo "Internet update"
	systemctl stop klipper

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
	cd /home/Volumic/klipper
	if [ -d "SAM3X8E" ]; then
		make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic flash FLASH_DEVICE=/dev/serial/by-path/platform-fd840000.usb-usb-0:1:1.0
	elif [ -d "STM32H723M8" ]; then
		make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta flash FLASH_DEVICE=/dev/serial/by-path/platform-xhci-hcd.4.auto-usb-0:1.4:1.0
	else
		make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.hyperlumic
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.hyperlumic
		cd /home/Volumic/klipper/lib/hidflash
		./hid-flash /home/Volumic/klipper/out/klipper.bin serial/by-path/platform-fd840000.usb-usb-0:1:1.0
		# make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.hyperlumic flash FLASH_DEVICE=/dev/serial/by-path/platform-fd840000.usb-usb-0:1:1.0
	fi

else	# no internet connexion

	echo "Local update"
	systemctl stop klipper

	# Update accelerometer MCU
	cd /home/Volumic/klipper
	make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
	make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
	sudo make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc flash FLASH_DEVICE=/dev/serial/by-path/platform-xhci-hcd.4.auto-usb-0:1:1.0

	# Update MCU
	cd /home/Volumic/klipper
	if [ -d "SAM3X8E" ]; then
		make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic flash FLASH_DEVICE=/dev/serial/by-path/platform-fd840000.usb-usb-0:1:1.0
	elif [ -d "STM32H723M8" ]; then
		make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta flash FLASH_DEVICE=/dev/serial/by-path/platform-xhci-hcd.4.auto-usb-0:1.4:1.0
	else
		make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.hyperlumic
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.hyperlumic
		cd /home/Volumic/klipper/lib/hidflash
		./hid-flash /home/Volumic/klipper/out/klipper.bin serial/by-path/platform-fd840000.usb-usb-0:1:1.0
	fi

fi

# Update Mainsail images
cp -f /home/Volumic/printer_data/config/.volumic/system/img/icons/*.* /home/Volumic/mainsail/img/icons/
cp -f /home/Volumic/printer_data/config/.volumic/system/img/themes/*.* /home/Volumic/mainsail/img/themes/
cp -f /home/Volumic/printer_data/config/.volumic/system/img/*.* /home/Volumic/mainsail/img/
cp -f /home/Volumic/printer_data/config/.volumic/system/KlipperScreen.conf /home/Volumic/printer_data/config
cp -f /home/Volumic/printer_data/config/.volumic/system/mainsail_style.css /home/Volumic/printer_data/config/.theme/custom.css

cd /home/Volumic/VyperOS
if [ -d "SAM3X8E" ]; then
	reboot
else
	sudo systemctl stop KlipperScreen 2>/dev/null || true
	sudo systemctl stop klipper 2>/dev/null || true
	sudo systemctl stop moonraker 2>/dev/null || true
	sudo plymouth quit --retain-splash 2>/dev/null || true
	sudo sh -c 'echo "" > /dev/tty1'
	sudo sh -c 'echo "" > /dev/tty1'
	sudo sh -c 'printf "\033[2J\033[H" > /dev/tty1'
	sudo sh -c 'echo "" > /dev/tty1'
	sudo sh -c 'echo " " > /dev/tty1'
	sudo sh -c 'echo " " > /dev/tty1'
	sudo sh -c 'echo " " > /dev/tty1'
	sudo sh -c 'echo " " > /dev/tty1'
	sudo sh -c 'echo "   MISE A JOUR INSTALLEE" > /dev/tty1'
	sudo sh -c 'echo "   ---------------------" > /dev/tty1'
	sudo sh -c 'echo " " > /dev/tty1'
	sudo sh -c 'echo "   Veuillez eteindre la machine electriquement" > /dev/tty1'
	sudo sh -c 'echo "   puis rallumez-la pour finaliser la configuration..." > /dev/tty1'
	sudo sh -c 'echo " " > /dev/tty1'
	sudo sh -c 'echo " " > /dev/tty1'
	sudo sh -c 'echo " " > /dev/tty1'
	sudo sh -c 'echo " " > /dev/tty1'
	sudo sh -c 'echo " " > /dev/tty1'
	sudo sh -c 'echo " " > /dev/tty1'
	sudo sh -c 'echo " " > /dev/tty1'
	sudo sh -c 'echo " " > /dev/tty1'
	sudo sh -c 'echo " " > /dev/tty1'
	sudo sh -c 'echo " " > /dev/tty1'
	sudo sh -c 'echo " " > /dev/tty1'
	sudo sh -c 'echo " " > /dev/tty1'
	sudo sh -c 'echo " " > /dev/tty1'
	sudo sh -c 'echo " " > /dev/tty1'
	sudo sh -c 'echo " " > /dev/tty1'
	sudo sh -c 'echo " " > /dev/tty1'
	sudo sh -c 'echo " " > /dev/tty1'
	sudo sh -c 'echo " " > /dev/tty1'
	sudo sh -c 'echo " " > /dev/tty1'
	sudo sh -c 'echo " " > /dev/tty1'
	sudo sh -c 'echo "   Après redémarrage, si toutes les mise à jour ne se sont pas installé," > /dev/tty1'
	sudo sh -c 'echo "   relancez une deuxième fois la mise à jour complète si necessaire." > /dev/tty1'
	sudo sh -c 'echo "" > /dev/tty1'
	cp -f /home/Volumic/printer_data/config/.volumic/system/*.sh /home/Volumic/VyperOS
	while true; do
		sync
		sleep 5
	done
	#sudo shutdown -h 1
fi

}
