#!/bin/bash
echo Arret des services web
sudo service nginx stop
echo Configuration du service...
cd /home/Volumic/VyperOS
if [ -d "ssl" ]; then
	rmdir ssl
fi
if [ -d "pwd" -a -d "ssl" ]; then
	echo SECURITY IS NOW SSL & PWD
	sudo cp /home/Volumic/printer_data/config/.volumic/system/mainsail_pwd_ssl /etc/nginx/sites-available/mainsail
fi
if [ -d "pwd" -a ! -d "ssl" ]; then
	echo SECURITY IS NOW PWD
	sudo cp /home/Volumic/printer_data/config/.volumic/system/mainsail_pwd /etc/nginx/sites-available/mainsail
fi
if [ ! -d "pwd" -a -d "ssl" ]; then
	echo SECURITY IS NOW SSL
	sudo cp /home/Volumic/printer_data/config/.volumic/system/mainsail_ssl /etc/nginx/sites-available/mainsail
fi
if [ ! -d "pwd" -a ! -d "ssl" ]; then
	echo NO SECURITY
	sudo cp /home/Volumic/printer_data/config/.volumic/system/mainsail /etc/nginx/sites-available/mainsail
fi
echo Redemarrage du service
sudo service nginx start
echo SSL supprimé avec succes. Accedez au site via HTTP://
