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

sudo chmod 666 /home/Volumic/printer_data/database/moonraker-sql.db

cd /home/Volumic/VyperOS
cp -f /home/Volumic/printer_data/config/.volumic/system/vyperos_pelletsupdate.sh /home/Volumic/VyperOS/vyperos_update.sh
sudo chmod +x *.sh

# One time system update
if [ ! -d "sys1" ]; then
	mkdir sys1
	cp -f /home/Volumic/printer_data/config/.volumic/system/systems2_update.sh /home/Volumic/VyperOS
	sudo chmod +x *.sh
	./systems2_update.sh > lastsysupdate.log
fi
