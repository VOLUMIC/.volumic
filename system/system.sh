#!/bin/bash
{

# Check VyperOS dir
cd /home/Volumic
if [ ! -d "VyperOS" ]; then
	mkdir VyperOS
	sudo chmod -R -v 776 SecureMemory
fi
# Update VyperOS updates scripts
cd /home/Volumic/VyperOS
if [ ! -d "updater" ]; then
	mkdir updater
fi
if [ ! -d "check1" ]; then
	mkdir check1
fi

sudo cp -f /home/Volumic/printer_data/config/.volumic/system/90-usb.rules /etc/udev/rules.d/90-usb.rules
sudo cp /home/Volumic/printer_data/config/.volumic/system/vyper-usb /etc/sudoers.d/vyper-usb
cp -u -f /home/Volumic/printer_data/config/.volumic/updater/*.* /home/Volumic/VyperOS/updater
cp -f /home/Volumic/printer_data/config/.volumic/system/*.sh /home/Volumic/VyperOS
cp -f /home/Volumic/printer_data/config/.volumic/system/KlipperScreen.conf /home/Volumic/printer_data/config/KlipperScreen.conf
sudo chmod +x /home/Volumic/VyperOS/updater/*.sh
sudo chmod +x /home/Volumic/VyperOS/*.sh
sudo chmod 666 /home/Volumic/printer_data/database/moonraker-sql.db

# One time system update
cd /home/Volumic/VyperOS
sudo chmod +x *.sh
if [ ! -d "sys1" ]; then
	mkdir sys1
	/home/Volumic/VyperOS/system_update.sh > lastsysupdate.log
fi

}
