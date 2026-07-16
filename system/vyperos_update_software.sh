#!/bin/bash

# Arret KlipperScreen en premier
sudo systemctl stop KlipperScreen 2>/dev/null || true
sleep 1

# Quitter Plymouth completement pour liberer le framebuffer (sans --retain-splash)
sudo plymouth quit 2>/dev/null || true
sleep 1

# Basculer sur tty1 - apres l'arret de X11, Armbian revient toujours sur tty1
sudo chvt 1 2>/dev/null || true
sleep 1

TTY_DEV="/dev/tty1"

# Fonctions d'affichage
tty_echo() {
    sudo sh -c "echo \"$1\" > $TTY_DEV"
}
tty_clear() {
    sudo sh -c "printf '\033[2J\033[H' > $TTY_DEV"
}
tty_echo ""
tty_echo ""
tty_clear
tty_echo ""
tty_echo "   MISE A JOUR VOLUMIC, VEUILLEZ PATIENTER..."
tty_echo " "

ping -q -c 2 www.google.fr >/dev/null 2>&1	# test if internet is connected

if [ $? -eq 0 ]; then	# internet connected

  tty_echo "-> Mise a jour Internet, arret des services VyperOS"
	sudo service klipper stop

	# Update KlipperScreen
  tty_echo "-> Mise a jour Affichage"
	cd /home/Volumic/KlipperScreen
	git reset --hard
	git clean -fd
	git pull

	# Update mainsail
  tty_echo "-> Mise a jour serveur Web"
	cd /home/Volumic/mainsail
	sudo rm -R -f ./*
	sudo rm .version
	wget -q -O mainsail.zip https://github.com/mainsail-crew/mainsail/releases/latest/download/mainsail.zip && unzip mainsail.zip && rm mainsail.zip

	# Update klipper
  tty_echo "-> Mise a jour noyau"
	cd /home/Volumic/klipper
	git pull

	# Update Moonraker
  tty_echo "-> Mise a jour API"
	cd /home/Volumic/moonraker
	git pull

	# Update Obico
  tty_echo "-> Mise a jour IA"
	cd /home/Volumic/moonraker-obico/
	git pull

	# Update accelerometer MCU
  tty_echo "-> Mise a jour firmware accelerometre"
	cd /home/Volumic/klipper
	make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
	make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
	sudo make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc flash FLASH_DEVICE=/dev/serial/by-path/platform-xhci-hcd.4.auto-usb-0:1:1.0

	# Update MCU
  tty_echo "-> Mise a jour firmware MCU"
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
  tty_echo "-> Mise a jour systeme"
	cd /home/Volumic/VyperOS
	if [ -d "sys1" ]; then
		rmdir sys1
	fi

else	# no internet connexion

  tty_echo "-> Mise a jour locale (firmware only)"
  tty_echo "-> Arret des services"
	sudo service klipper stop

	# Update accelerometer MCU
  tty_echo "-> Mise a jour accelerometre"
	cd /home/Volumic/klipper
	make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
	make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
	sudo make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc flash FLASH_DEVICE=/dev/serial/by-path/platform-xhci-hcd.4.auto-usb-0:1:1.0

	# Update MCU
  tty_echo "-> Mise a jour MCU"
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
	#sudo systemctl stop KlipperScreen 2>/dev/null || true
	#sudo plymouth quit --retain-splash 2>/dev/null || true
	tty_echo ""
	tty_echo ""
	tty_clear
	tty_echo ""
	tty_echo "   MISE A JOUR INTERNET TERMINEE"
	tty_echo " "
	tty_echo "   Veuillez eteindre la machine electriquement"
	tty_echo "   puis rallumez-la pour finaliser la mise a jour..."
	tty_echo ""
	#sudo shutdown -h 0
fi