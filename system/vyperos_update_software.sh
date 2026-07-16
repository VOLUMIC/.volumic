#!/bin/bash

# Arret KlipperScreen
sudo systemctl stop KlipperScreen 2>/dev/null || true
sleep 1

# Quitter Plymouth completement
sudo plymouth quit 2>/dev/null || true
sleep 1

# Ouvrir un nouveau VT vierge avec openvt et y afficher les messages
# openvt -s = switche automatiquement sur ce VT
# openvt -w = attend la fin de la commande
# On lance un shell qui reste ouvert et affiche les messages via /proc/self/fd/1
FIFO=/tmp/vyper_update_fifo
rm -f $FIFO
mkfifo $FIFO

# Lancer un afficheur sur un VT dedie en arriere plan
sudo openvt -s -w -- bash -c "
    clear
    cat $FIFO
    echo ''
    echo '   FIN - Vous pouvez lire le resultat ci-dessus'
    sleep 9999
" &
OPENVT_PID=$!
sleep 1

# Fonction d'affichage via le fifo
tty_echo() {
    echo "$1" >> $FIFO
}
tty_clear() {
    echo "" >> $FIFO
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
	# Fermer le fifo avant reboot
	exec 3>$FIFO; exec 3>&-
	rm -f $FIFO
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
	# Fermer le fifo - le message reste affiche sur le VT grace au sleep 9999
	exec 3>$FIFO; exec 3>&-
	#sudo shutdown -h 0
fi