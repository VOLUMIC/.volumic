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

# Update Mainsail images
sudo cp -f /home/Volumic/printer_data/config/.volumic/system/img/icons/*.* /home/Volumic/mainsail/img/icons/
sudo cp -f /home/Volumic/printer_data/config/.volumic/system/img/themes/*.* /home/Volumic/mainsail/img/themes/
sudo cp -f /home/Volumic/printer_data/config/.volumic/system/img/*.* /home/Volumic/mainsail/img/

# Update configs
sudo cp -f /home/Volumic/printer_data/config/.volumic/system/KlipperScreen.conf /home/Volumic/printer_data/config
sudo cp -f /home/Volumic/printer_data/config/.volumic/system/mainsail_style.css /home/Volumic/printer_data/config/.theme/custom.css

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
