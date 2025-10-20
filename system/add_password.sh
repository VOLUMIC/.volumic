#!/bin/bash
echo Mise a jour du systeme...
sudo cp -f /home/Volumic/printer_data/config/.volumic/system/sources.list /etc/apt/sources.list
sudo cp /etc/nginx/sites-available/mainsail  /etc/nginx/sites-available/mainsail.orig
sleep 1s
sudo apt update
sudo apt install apache2-utils
clear
echo Definition du mot de passe
sudo htpasswd -c /etc/nginx/.htpasswd Volumic
sleep 1s
cd /home/Volumic/VyperOS
if [ ! -d "pwd" ]; then
	mkdir pwd
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
echo Redemarrage service
sudo service nginx restart
echo Mot de passe ajouté avec succes