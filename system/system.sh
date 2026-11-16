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

# Sonar (maintien du Wi-Fi) : lien /usr/local/bin/sonar casse dans l'image (ancien utilisateur
# biqu), le service redemarrait toutes les 5 s en permanence ; sonar.conf est a "enable: false".
# Arrete et desactive une fois, masque si possible (retour : systemctl unmask sonar && systemctl enable --now sonar)
if [ "$(systemctl is-enabled sonar.service 2>/dev/null)" = "enabled" ] || systemctl is-failed --quiet sonar.service 2>/dev/null; then
	sudo systemctl disable --now sonar.service >/dev/null 2>&1
	sudo systemctl mask sonar.service >/dev/null 2>&1
	sudo systemctl reset-failed sonar.service >/dev/null 2>&1
fi

# Ecran 5 pouces inverse (VS30 ULTRA Performance) : remet a chaque demarrage ce qu'une
# mise a jour aurait annule (theme de demarrage, logo u-boot, console). Sans effet sur
# les autres machines (ks_angle="inverted" absent de /boot/system.cfg).
bash /home/Volumic/printer_data/config/.volumic/system/ecran_ultra_perf.sh verifier

}
