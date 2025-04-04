#!/bin/bash

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

# One time system update
cd /home/Volumic/VyperOS
cp -f /home/Volumic/printer_data/config/.volumic/system/vyperos_update.sh /home/Volumic/VyperOS
sudo chmod +x *.sh
if [ ! -d "sys1" ]; then
	mkdir sys1
	cp -f /home/Volumic/printer_data/config/.volumic/system/system_update.sh /home/Volumic/VyperOS
	sudo chmod +x *.sh
	./system_update.sh > lastsysupdate.log
fi
