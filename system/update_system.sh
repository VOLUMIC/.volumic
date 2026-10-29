#!/bin/bash
# =============================================================================
# VyperOS - mise a jour du systeme (bouton "Systeme" de l'ecran de mise a jour)
# Meme traitement que le demarrage qui suit une mise a jour complete :
# fichiers systeme + migrations + paquets apt (voir system_update.sh)
# =============================================================================
{
ping -q -c 2 -W 3 8.8.8.8 >/dev/null 2>&1	# test if internet is connected
if [ $? -eq 0 ]; then	# internet connected
	cp -f /home/Volumic/printer_data/config/.volumic/system/*.sh /home/Volumic/VyperOS
	chmod 755 /home/Volumic/VyperOS/*.sh
	bash /home/Volumic/printer_data/config/.volumic/system/system_update.sh
fi
}
