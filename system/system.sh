#!/bin/bash
{

# Check VyperOS dir
cd /home/Volumic
if [ ! -d "VyperOS" ]; then
	mkdir VyperOS
fi
# Update VyperOS updates scripts
cd /home/Volumic/VyperOS
if [ ! -d "updater" ]; then
	mkdir updater
fi

# One time system update
cd /home/Volumic/VyperOS
sudo chmod +x *.sh
if [ ! -d "sys1" ]; then
	mkdir sys1
	sudo cp /home/Volumic/printer_data/config/.volumic/system/vyper-usb /etc/sudoers.d/vyper-usb
	/home/Volumic/VyperOS/system_update.sh > lastsysupdate.log
fi

# Ecran 5 pouces inverse (VS30 ULTRA Performance) : remet a chaque demarrage ce qu'une
# mise a jour aurait annule (theme de demarrage, logo u-boot, console). Sans effet sur
# les autres machines (ks_angle="inverted" absent de /boot/system.cfg).
bash /home/Volumic/printer_data/config/.volumic/system/ecran_ultra_perf.sh verifier

}
