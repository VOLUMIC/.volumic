#!/bin/bash
echo Arret des services web
sudo service nginx stop
sudo cp -f /home/Volumic/printer_data/config/.volumic/system/sources.list /etc/apt/sources.list
sudo cp /etc/nginx/sites-available/mainsail  /etc/nginx/sites-available/mainsail.orig
echo Mise a jour du systeme
sudo apt update
sudo apt install openssl
clear
echo Creation de la clé SSL
echo ----------------------
sudo openssl req -x509 -nodes -days 36500 -newkey rsa:2048  -keyout /etc/nginx/vyperos.key  -out /etc/nginx/vyperos.crt
echo Configuration des services et demarrage...
cd /home/Volumic/VyperOS
if [ ! -d "ssl" ]; then
	mkdir ssl
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
sudo service nginx start
echo SSL installé avec succes. Accedez au site via HTTPS://
