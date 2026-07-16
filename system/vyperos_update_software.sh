#!/bin/bash

sudo systemctl stop KlipperScreen 2>/dev/null || true
sudo plymouth quit --retain-splash 2>/dev/null || true
sudo sh -c 'echo "" > /dev/tty1'
sudo sh -c 'echo "" > /dev/tty1'
sudo sh -c 'printf "\033[2J\033[H" > /dev/tty1'
sudo sh -c 'echo "" > /dev/tty1'
sudo sh -c 'echo "   MISE A JOUR VOLUMIC, VEUILLEZ PATIENTER..." > /dev/tty1'
sudo sh -c 'echo " " > /dev/tty1'

ping -q -c 2 www.google.fr >/dev/null 2>&1	# test if internet is connected

if [ $? -eq 0 ]; then	# internet connected

  sudo sh -c 'echo "-> Mise a jour Internet, arret des services VyperOS" > /dev/tty1'
	sudo service klipper stop

	# Update KlipperScreen
  sudo sh -c 'echo "-> Mise a jour Affichage" > /dev/tty1'
	cd /home/Volumic/KlipperScreen
	git reset --hard
	git clean -fd
	git pull

	# Update mainsail
  sudo sh -c 'echo "-> Mise a jour serveur Web" > /dev/tty1'
	cd /home/Volumic/mainsail
	rm -R -f ./*
	rm .version
	wget -q -O mainsail.zip https://github.com/mainsail-crew/mainsail/releases/latest/download/mainsail.zip && unzip mainsail.zip && rm mainsail.zip

	# Update klipper
  sudo sh -c 'echo "-> Mise a jour noyau" > /dev/tty1'
	cd /home/Volumic/klipper
	git pull

	# Update Moonraker
  sudo sh -c 'echo "-> Mise a jour API" > /dev/tty1'
	cd /home/Volumic/moonraker
	git pull

	# Update Obico
  sudo sh -c 'echo "-> Mise a jour IA" > /dev/tty1'
	cd /home/Volumic/moonraker-obico/
	git pull

	# Update accelerometer MCU
  sudo sh -c 'echo "-> Mise a jour firmware accelerometre" > /dev/tty1'
	cd /home/Volumic/klipper
	make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
	make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
	sudo make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc flash FLASH_DEVICE=/dev/serial/by-path/platform-xhci-hcd.4.auto-usb-0:1:1.0

	# Update MCU
  sudo sh -c 'echo "-> Mise a jour firmware MCU" > /dev/tty1'
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
  sudo sh -c 'echo "-> Mise a jour systeme" > /dev/tty1'
	cd /home/Volumic/VyperOS
	if [ -d "sys1" ]; then
		rmdir sys1
	fi

else	# no internet connexion

  sudo sh -c 'echo "-> Mise a jour locale (firmware only)" > /dev/tty1'
  sudo sh -c 'echo "-> Arret des services" > /dev/tty1'
	sudo service klipper stop

	# Update accelerometer MCU
  sudo sh -c 'echo "-> Mise a jour accelerometre" > /dev/tty1'
	cd /home/Volumic/klipper
	make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
	make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
	sudo make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc flash FLASH_DEVICE=/dev/serial/by-path/platform-xhci-hcd.4.auto-usb-0:1:1.0

	# Update MCU
  sudo sh -c 'echo "-> Mise a jour MCU" > /dev/tty1'
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

sudo cp -f /home/Volumic/printer_data/config/.volumic/system/img/icons/*.* /home/Volumic/mainsail/img/icons/
sudo cp -f /home/Volumic/printer_data/config/.volumic/system/img/themes/*.* /home/Volumic/mainsail/img/themes/
sudo cp -f /home/Volumic/printer_data/config/.volumic/system/img/*.* /home/Volumic/mainsail/img/
sudo cp -f /home/Volumic/printer_data/config/.volumic/system/KlipperScreen.conf /home/Volumic/printer_data/config
sudo cp -f /home/Volumic/printer_data/config/.volumic/system/mainsail_style.css /home/Volumic/printer_data/config/.theme/custom.css

cd /home/Volumic/VyperOS
if [ -d "SAM3X8E" ]; then
	reboot
else
	sudo systemctl stop KlipperScreen 2>/dev/null || true
	sudo plymouth quit --retain-splash 2>/dev/null || true
	sudo sh -c 'echo "" > /dev/tty1'
	sudo sh -c 'echo "" > /dev/tty1'
	sudo sh -c 'printf "\033[2J\033[H" > /dev/tty1'  # efface l ecran
	sudo sh -c 'echo "" > /dev/tty1'
	sudo sh -c 'echo "   MISE A JOUR INTERNET TERMINEE" > /dev/tty1'
	sudo sh -c 'echo " " > /dev/tty1'
	sudo sh -c 'echo "   Veuillez eteindre la machine electriquement" > /dev/tty1'
	sudo sh -c 'echo "   puis rallumez-la pour finaliser la mise a jour..." > /dev/tty1'
	sudo sh -c 'echo "" > /dev/tty1'
	#sudo shutdown -h 0
fi
