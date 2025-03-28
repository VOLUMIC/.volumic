#!/bin/bash

# Update klipper
cd /home/Volumic/klipper
git pull

# Update configurations
cd /home/Volumic/printer_data/config/.volumic
git pull

# Update KlipperScreen
cd /home/Volumic/KlipperScreen
#git reset --hard
#git clean -fd
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

shutdown -h 0
#reboot
