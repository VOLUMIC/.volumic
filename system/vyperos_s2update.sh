#!/bin/bash

# Update klipper
cd /home/Volumic/klipper
git pull

# Update configurations
cd /home/Volumic/printer_data/config/.volumic
git pull

# Update KlipperScreen
cd /home/Volumic/KlipperScreen
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
make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc flash FLASH_DEVICE=/dev/serial/by-path/platform-5200000.usb-usb-0:1.4:1.0

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

reboot
