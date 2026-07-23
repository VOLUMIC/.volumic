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
	sudo chmod -R -v 776 SecureMemory
fi

cp -u -f /home/Volumic/printer_data/config/.volumic/updater/*.* updater
sudo chmod +x updater/*.sh
sudo chmod 666 /home/Volumic/printer_data/database/moonraker-sql.db

# One time system update
cd /home/Volumic/VyperOS
sudo chmod +x *.sh
if [ ! -d "sys1" ]; then
	mkdir sys1
	sudo cp -f /home/Volumic/printer_data/config/.volumic/system/90-usb.rules /etc/udev/rules.d/90-usb.rules
	sudo cp /home/Volumic/printer_data/config/.volumic/system/vyper-usb /etc/sudoers.d/vyper-usb
	cd /home/Volumic/VyperOS
	cp -u -f /home/Volumic/printer_data/config/.volumic/updater/*.* updater
	cp -f /home/Volumic/printer_data/config/.volumic/system/*.sh /home/Volumic/VyperOS
	cp -f /home/Volumic/printer_data/config/.volumic/system/KlipperScreen.conf /home/Volumic/printer_data/config/KlipperScreen.conf
	sudo chmod 776 updater/*.sh
	sudo chmod 776 *.sh
	/home/Volumic/VyperOS/system_update.sh > lastsysupdate.log
fi

}
