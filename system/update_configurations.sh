#!/bin/bash
{
if [ "$(id -u)" = "0" ]; then
    export HOME=/root
fi
export GIT_CONFIG_GLOBAL="${HOME}/.gitconfig"
git config --global --replace-all safe.directory '*'
git config --global pull.rebase false

ping -q -c 2 -W 3 8.8.8.8 >/dev/null 2>&1	# test if internet is connected
if [ $? -eq 0 ]; then	# internet connected

	sudo service klipper stop

	# Update configurations
	cd /home/Volumic/printer_data/config/.volumic
	git reset --hard
	git clean -fd
	git pull
	cp -u -f /home/Volumic/printer_data/config/.volumic/updater/*.* /home/Volumic/VyperOS/updater
	sudo chmod 776 /home/Volumic/VyperOS/updater/*.sh
	HKS=/home/Volumic/VyperOS/ksconf_merge.sh; [ -f "$HKS" ] || HKS=/home/Volumic/printer_data/config/.volumic/system/ksconf_merge.sh; bash "$HKS"  # KlipperScreen.conf : menus du depot + reglages client conserves
	cd /home/Volumic
	if [ -d "Moonraker-loader" ]; then
		mv /home/Volumic/Moonraker-loader /home/Volumic/Moonraker-loader.old
	fi

	cp -f /home/Volumic/printer_data/config/.volumic/system/*.sh /home/Volumic/VyperOS
	# Fichiers systeme et migrations (system_files.list, system/migrations/) depuis le depot a jour
	bash /home/Volumic/printer_data/config/.volumic/system/system_update.sh --files
	sudo chmod 776 /home/Volumic/VyperOS/*.sh
	sudo service klipper start
fi
}
