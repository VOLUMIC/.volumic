#!/bin/bash
{
export HOME=/root
export GIT_CONFIG_GLOBAL=/root/.gitconfig
sudo git config --global --replace-all safe.directory '*'

sudo systemctl stop klipper 2>/dev/null || true
sudo systemctl stop moonraker 2>/dev/null || true
sudo systemctl stop KlipperScreen 2>/dev/null || true
sudo plymouth quit 2>/dev/null || true
sleep 2
sudo openvt -c 3 -s -f -- bash -c '
	echo "" > /dev/tty3
	echo "" > /dev/tty3
	printf "\033[2J\033[H" > /dev/tty3
	echo "" > /dev/tty3
	echo " " > /dev/tty3
	echo " " > /dev/tty3
	echo " " > /dev/tty3
	echo " " > /dev/tty3
	echo "   MISE A JOUR EN COURS, PATIENTEZ..." > /dev/tty3
	echo "   ----------------------------------" > /dev/tty3
'
ping -q -c 2 -W 3 8.8.8.8 >/dev/null 2>&1	# test if internet is connected
if [ $? -eq 0 ]; then	# internet connected

	sudo openvt -c 3 -s -f -- bash -c 'echo " -> Core update" > /dev/tty3'
	# Update klipper
	cd /home/Volumic/klipper
	git pull

fi

# Update MCU
cd /home/Volumic/VyperOS/
if [ -d "SAM3X8E" ]; then
	cd /home/Volumic/klipper
	make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic
	make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic
	make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic flash FLASH_DEVICE=/dev/serial/by-path/platform-fd840000.usb-usb-0:1:1.0
elif [ -d "STM32H723M8" ]; then
	# Update accelerometer MCU
	cd /home/Volumic/klipper
	make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
	make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
	sudo make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc flash FLASH_DEVICE=/dev/serial/by-path/platform-xhci-hcd.4.auto-usb-0:1:1.0
	# Update MCU
	make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta
	make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta
	make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta flash FLASH_DEVICE=/dev/serial/by-path/platform-xhci-hcd.4.auto-usb-0:1.4:1.0
else
	# Update accelerometer MCU
	sudo openvt -c 3 -s -f -- bash -c 'echo " -> Accelerometer update" > /dev/tty3'
	cd /home/Volumic/klipper
	make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
	make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
	sudo openvt -c 3 -s -f -- bash -c 'echo " -> Firmware flash" > /dev/tty3'
	sudo make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc flash FLASH_DEVICE=/dev/serial/by-path/platform-xhci-hcd.4.auto-usb-0:1:1.0
	# Update MCU
	sudo openvt -c 3 -s -f -- bash -c 'echo " -> MCU update" > /dev/tty3'
	make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.hyperlumic
	make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.hyperlumic
	sudo openvt -c 3 -s -f -- bash -c 'echo " -> Firmware flash" > /dev/tty3'
	cd /home/Volumic/klipper/lib/hidflash
	./hid-flash /home/Volumic/klipper/out/klipper.bin serial/by-path/platform-fd840000.usb-usb-0:1:1.0
	# make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.hyperlumic flash FLASH_DEVICE=/dev/serial/by-path/platform-fd840000.usb-usb-0:1:1.0
	sudo openvt -c 3 -s -f -- bash -c 'echo " -> Finished !" > /dev/tty3'
fi

cd /home/Volumic/VyperOS
if [ -d "SAM3X8E" ]; then
	reboot
else
	sudo systemctl stop KlipperScreen 2>/dev/null || true
	sudo systemctl stop klipper 2>/dev/null || true
	sudo systemctl stop moonraker 2>/dev/null || true
	sudo plymouth quit 2>/dev/null || true
	sudo openvt -c 3 -s -f -- bash -c '
		echo "" > /dev/tty3
		echo "" > /dev/tty3
		printf "\033[2J\033[H" > /dev/tty3
		echo "" > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo "   MISES A JOUR INSTALLEE" > /dev/tty3
		echo "   ----------------------" > /dev/tty3
		echo " " > /dev/tty3
		echo "   Veuillez eteindre la machine electriquement" > /dev/tty3
		echo "   puis rallumez-la pour finaliser la configuration..." > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo "   Après redémarrage, si toutes les mise à jour ne se sont pas installé," > /dev/tty3
		echo "   relancez une deuxième fois la mise à jour complète si necessaire." > /dev/tty3
		echo "" > /dev/tty3
	'
	while true; do
		sync
		sleep 5
	done
fi
}
