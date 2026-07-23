#!/bin/bash

# update sudo rights
sudo cp /home/Volumic/printer_data/config/.volumic/system/vyper-usb /etc/sudoers.d/vyper-usb
sudo chmod 440 /etc/sudoers.d/vyper-usb
# update VyperOS
sudo cp -f /home/Volumic/printer_data/config/.volumic/system/90-usb.rules /etc/udev/rules.d/90-usb.rules
cp -u -f /home/Volumic/printer_data/config/.volumic/updater/*.* /home/Volumic/VyperOS/updater
cp -f /home/Volumic/printer_data/config/.volumic/system/*.sh /home/Volumic/VyperOS
cp -f /home/Volumic/printer_data/config/.volumic/system/KlipperScreen.conf /home/Volumic/printer_data/config/KlipperScreen.conf
sudo chmod +x /home/Volumic/VyperOS/updater/*.sh
sudo chmod +x /home/Volumic/VyperOS/*.sh
sudo chmod 666 /home/Volumic/printer_data/database/moonraker-sql.db

# update repository list
sudo cp -f /home/Volumic/printer_data/config/.volumic/system/sources.list /etc/apt/

# Update system
sudo killall unattended-upgrades 2>/dev/null || true # Liberer les locks eventuels
while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
	sleep 2
done
# Mise a jour
sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq
# Finaliser
sudo dpkg --configure -a
sudo apt-get install -f -y
# Verifier que dpkg est vraiment fini
while sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1; do
	sleep 1
done
# update splash
sudo cp -f /home/Volumic/printer_data/config/.volumic/system/watermark.png /usr/share/plymouth/themes/armbian/
sudo plymouth-set-default-theme -R armbian
