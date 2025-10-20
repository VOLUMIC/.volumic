#!/bin/bash
cd /home/Volumic/VyperOS
if [ -d "pwd" ]; then
	echo Suppression du mot de passe
	rmdir pwd
fi
echo Configuration du service...
if [ -d "pwd" -a -d "ssl" ]; then
	#echo SECURITY IS NOW SSL & PWD
	sudo cp /home/Volumic/printer_data/config/.volumic/system/mainsail_pwd_ssl /etc/nginx/sites-available/mainsail
fi
if [ -d "pwd" -a ! -d "ssl" ]; then
	#echo SECURITY IS NOW PWD
	sudo cp /home/Volumic/printer_data/config/.volumic/system/mainsail_pwd /etc/nginx/sites-available/mainsail
fi
if [ ! -d "pwd" -a -d "ssl" ]; then
	#echo SECURITY IS NOW SSL
	sudo cp /home/Volumic/printer_data/config/.volumic/system/mainsail_ssl /etc/nginx/sites-available/mainsail
fi
if [ ! -d "pwd" -a ! -d "ssl" ]; then
	#echo NO SECURITY
	sudo cp /home/Volumic/printer_data/config/.volumic/system/mainsail /etc/nginx/sites-available/mainsail
fi
echo Redemarrage du service
sudo service nginx restart
echo Mot de passe supprime avec succes.
