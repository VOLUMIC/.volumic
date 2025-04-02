#!/bin/bash

ping -q -c 2 www.google.fr >/dev/null 2>&1	# test if internet is connected
if [ $? -eq 0 ]; then	# internet connected

	# Update configurations
	cd /home/Volumic/printer_data/config/.volumic
	git reset --hard
	git clean -fd
	git pull

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
	sudo make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc flash FLASH_DEVICE=/dev/serial/by-path/platform-xhci-hcd.4.auto-usb-0:1:1.0

	# Update MCU
	cd /home/Volumic/klipper
	make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.hyperlumic
	make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.hyperlumic
	cd /home/Volumic/klipper/lib/hidflash
	./hid-flash /home/Volumic/klipper/out/klipper.bin serial/by-path/platform-fd840000.usb-usb-0:1:1.0

	# Force system update after boot
	cd /home/Volumic/VyperOS
	if [ -d "sys1" ]; then
		rmdir sys1
	fi

else	# no internet connexion

	# Update USB Loader
	sudo ln -sf ~/Moonraker-loader/assets/89-moonraker-loader.rules /etc/udev/rules.d
	sudo ln -sf ~/Moonraker-loader/assets/*.sh /usr/local/sbin

	# Update accelerometer MCU
	cd /home/Volumic/klipper
	make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
	make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
	sudo make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc flash FLASH_DEVICE=/dev/serial/by-path/platform-xhci-hcd.4.auto-usb-0:1:1.0

	# Update MCU
	cd /home/Volumic/klipper
	make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.hyperlumic
	make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.hyperlumic
	cd /home/Volumic/klipper/lib/hidflash
	./hid-flash /home/Volumic/klipper/out/klipper.bin serial/by-path/platform-fd840000.usb-usb-0:1:1.0

fi 

shutdown -h 0
#reboot
