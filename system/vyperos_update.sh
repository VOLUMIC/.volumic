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

	# Force system update after boot
	cd /home/Volumic/VyperOS
	if [ -d "sys1" ]; then
		rmdir sys1
	fi

	echo "Internet update"
	systemctl stop klipper

	# Update configurations
	cd /home/Volumic/printer_data/config/.volumic
	git reset --hard
	git clean -fd
	git pull
	cp -f /home/Volumic/printer_data/config/.volumic/system/*.sh /home/Volumic/VyperOS
	# Fichiers systeme, migrations et paquets : appliques au redemarrage par system_update.sh (sys1 retire)
	sudo chmod 776 /home/Volumic/VyperOS/updater/*.sh
	sudo chmod 776 /home/Volumic/VyperOS/*.sh
	cp -u -f /home/Volumic/printer_data/config/.volumic/updater/*.* /home/Volumic/VyperOS/updater
	HKS=/home/Volumic/VyperOS/ksconf_merge.sh; [ -f "$HKS" ] || HKS=/home/Volumic/printer_data/config/.volumic/system/ksconf_merge.sh; bash "$HKS"  # KlipperScreen.conf : menus du depot + reglages client conserves
	cd /home/Volumic
	if [ -d "Moonraker-loader" ]; then
		mv /home/Volumic/Moonraker-loader /home/Volumic/Moonraker-loader.old
	fi

	# Update KlipperScreen
	cd /home/Volumic/KlipperScreen
	git reset --hard
	git clean -fd
	git pull

	# Update mainsail
	cd /home/Volumic/mainsail
	rm -R -f ./*
	rm .version
	wget -q -O mainsail.zip https://github.com/mainsail-crew/mainsail/releases/latest/download/mainsail.zip && unzip mainsail.zip && rm mainsail.zip

	# Update klipper
	cd /home/Volumic/klipper
	git reset --hard
	git clean -fd
	git pull

	# Update Moonraker
	cd /home/Volumic/moonraker
	git reset --hard
	git clean -fd
	git pull

	# Update Obico (si installe) : code, dependances Python, fichiers rendus a Volumic (le script tourne en root)
	if [ -d "/home/Volumic/moonraker-obico/.git" ]; then
		cd /home/Volumic/moonraker-obico/
		git reset --hard
		git clean -fd
		git pull
		if [ -x /home/Volumic/moonraker-obico-env/bin/pip ] && [ -f requirements.txt ]; then
			/home/Volumic/moonraker-obico-env/bin/pip install -q -r requirements.txt
		fi
		chown -R Volumic:Volumic /home/Volumic/moonraker-obico /home/Volumic/moonraker-obico-env 2>/dev/null || true
	fi

	cd /home/Volumic/VyperOS/
	if [ -d "SAM3X8E" ]; then
		cd /home/Volumic/klipper
		# Update MCU
		make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic flash FLASH_DEVICE=/dev/serial/by-path/platform-fd840000.usb-usb-0:1:1.0
	elif [ -d "STM32H723M8" ]; then
		cd /home/Volumic/klipper
		# Update accelerometer MCU
		make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
		sudo make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc flash FLASH_DEVICE=/dev/serial/by-path/platform-xhci-hcd.4.auto-usb-0:1:1.0
		# Update MCU
		make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta flash FLASH_DEVICE=/dev/serial/by-path/platform-xhci-hcd.4.auto-usb-0:1.4:1.0
	elif [ -d "STM32F103" ]; then
		cd /home/sovol/klipper
		make clean KCONFIG_CONFIG=/home/sovol/VyperOS/updater/config.f103
		make KCONFIG_CONFIG=/home/sovol/VyperOS/updater/config.f103
		make KCONFIG_CONFIG=/home/sovol/VyperOS/updater/config.f103 flash FLASH_DEVICE=/dev/serial/by-path/platform-5101400.usb-usb-0:1:1.0
		make KCONFIG_CONFIG=/home/sovol/VyperOS/updater/config.f103 flash FLASH_DEVICE=/dev/serial/by-path/platform-5200400.usb-usb-0:1:1.0
	else
		# Update accelerometer MCU
		cd /home/Volumic/klipper
		make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
		sudo make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc flash FLASH_DEVICE=/dev/serial/by-path/platform-xhci-hcd.4.auto-usb-0:1:1.0
		# Update MCU
		cd /home/Volumic/klipper
		make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.hyperlumic
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.hyperlumic
		# Flash par la copie VyperOS (repli sur la copie du depot, lancee par bash : pas besoin du droit d'execution)
		HFS=/home/Volumic/VyperOS/hidflash_safe.sh; [ -f "$HFS" ] || HFS=/home/Volumic/printer_data/config/.volumic/system/hidflash_safe.sh
		bash "$HFS" /home/Volumic/klipper/out/klipper.bin serial/by-path/platform-fd840000.usb-usb-0:1:1.0
		# make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.hyperlumic flash FLASH_DEVICE=/dev/serial/by-path/platform-fd840000.usb-usb-0:1:1.0
	fi

else	# no internet connexion

	echo "Local update"
	systemctl stop klipper

	cd /home/Volumic/VyperOS/
	if [ -d "SAM3X8E" ]; then
		cd /home/Volumic/klipper
		# Update MCU
		make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic flash FLASH_DEVICE=/dev/serial/by-path/platform-fd840000.usb-usb-0:1:1.0
	elif [ -d "STM32H723M8" ]; then
		# Update accelerometer MCU
		cd /home/Volumic/klipper
		make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
		sudo make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc flash FLASH_DEVICE=/dev/serial/by-path/platform-xhci-hcd.4.auto-usb-0:1:1.0
		# Update MCU
		make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta flash FLASH_DEVICE=/dev/serial/by-path/platform-xhci-hcd.4.auto-usb-0:1.4:1.0
	else
		# Update accelerometer MCU
		cd /home/Volumic/klipper
		make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
		sudo make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc flash FLASH_DEVICE=/dev/serial/by-path/platform-xhci-hcd.4.auto-usb-0:1:1.0
		# Update MCU
		make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.hyperlumic
		make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.hyperlumic
		# Flash par la copie VyperOS (repli sur la copie du depot, lancee par bash : pas besoin du droit d'execution)
		HFS=/home/Volumic/VyperOS/hidflash_safe.sh; [ -f "$HFS" ] || HFS=/home/Volumic/printer_data/config/.volumic/system/hidflash_safe.sh
		bash "$HFS" /home/Volumic/klipper/out/klipper.bin serial/by-path/platform-fd840000.usb-usb-0:1:1.0
	fi

fi

# Update Mainsail images
cp -f /home/Volumic/printer_data/config/.volumic/system/img/icons/*.* /home/Volumic/mainsail/img/icons/
cp -f /home/Volumic/printer_data/config/.volumic/system/img/themes/*.* /home/Volumic/mainsail/img/themes/
cp -f /home/Volumic/printer_data/config/.volumic/system/img/*.* /home/Volumic/mainsail/img/
HKS=/home/Volumic/VyperOS/ksconf_merge.sh; [ -f "$HKS" ] || HKS=/home/Volumic/printer_data/config/.volumic/system/ksconf_merge.sh; bash "$HKS"  # KlipperScreen.conf : menus du depot + reglages client conserves
cp -f /home/Volumic/printer_data/config/.volumic/system/mainsail_style.css /home/Volumic/printer_data/config/.theme/custom.css

# Correctif DOOR_DETECT : retire le "gcode:" vide sous variable_dooractive dans printer.cfg (anciens modeles EXO42 P / IDRE)
python3 - /home/Volumic/printer_data/config/printer.cfg <<'PYEOF' || true
import re, sys
p = sys.argv[1]
try:
    s = open(p, encoding='utf-8', newline='').read()
except OSError:
    sys.exit(0)
t = re.sub(r'(\[gcode_macro DOOR_DETECT\][ \t]*\r?\nvariable_dooractive:[^\r\n]*\r?\n)gcode:[ \t]*\r?\n(?![ \t]+\S)', r'\1', s)
if t != s:
    open(p + '.bak_door', 'w', encoding='utf-8', newline='').write(s)
    open(p, 'w', encoding='utf-8', newline='').write(t)
    print("printer.cfg : DOOR_DETECT corrige")
PYEOF

# Auto-reparation des totaux d'historique NULL (base livree en mars 2025) : sinon Moonraker plante a chaque fin d'impression
if curl -s -f -m 10 "http://127.0.0.1:7125/server/history/totals" | python3 -c 'import sys, json; t = json.load(sys.stdin)["result"]["job_totals"]; sys.exit(0 if any(v is None for v in t.values()) else 1)' 2>/dev/null; then
	curl -s -f -m 30 -X POST "http://127.0.0.1:7125/server/history/reset_totals" >/dev/null 2>&1 && echo "Historique : totaux NULL reinitialises"
fi

cd /home/Volumic/VyperOS
if [ -d "SAM3X8E" ]; then
	reboot
else
	sudo systemctl stop klipper 2>/dev/null || true
	sudo systemctl stop moonraker 2>/dev/null || true
	sudo systemctl stop KlipperScreen 2>/dev/null || true
	sudo plymouth quit 2>/dev/null || true
	sudo openvt -c 3 -s -f -- bash -c '
		echo "" > /dev/tty3
		echo "" > /dev/tty3
		printf "\033[2J\033[H" > /dev/tty3
		echo "" > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo "   MISES A JOUR INSTALLEE" > /dev/tty3
		echo "   ----------------------" > /dev/tty3
		echo " " > /dev/tty3
		echo "   Veuillez eteindre la machine electriquement" > /dev/tty3
		echo "   puis rallumez-la pour finaliser la configuration..." > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo " " > /dev/tty3
		echo "   Après redémarrage, si toutes les mise à jour ne se sont pas installé," > /dev/tty3
		echo "   relancez une deuxième fois la mise à jour complète si necessaire." > /dev/tty3
		echo "" > /dev/tty3
	'
	cp -f /home/Volumic/printer_data/config/.volumic/system/*.sh /home/Volumic/VyperOS
	sudo chmod 776 /home/Volumic/VyperOS/updater/*.sh
	sudo chmod 776 /home/Volumic/VyperOS/*.sh
	while true; do
		sync
		sleep 5
	done
fi

}
