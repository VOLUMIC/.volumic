#!/bin/bash

sudo service klipper stop
ping -q -c 2 www.google.fr >/dev/null 2>&1	# test if internet is connected
if [ $? -eq 0 ]; then	# internet connected

	# Update klipper
	cd /home/Volumic/klipper
	git pull

fi

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
