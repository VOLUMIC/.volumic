#!/bin/bash
{

# update sudo rights
sudo cp /home/Volumic/printer_data/config/.volumic/system/vyper-usb /etc/sudoers.d/vyper-usb
sudo chmod 440 /etc/sudoers.d/vyper-usb
# update VyperOS
sudo cp -f /home/Volumic/printer_data/config/.volumic/system/90-usb.rules /etc/udev/rules.d/90-usb.rules
cp -u -f /home/Volumic/printer_data/config/.volumic/updater/*.* /home/Volumic/VyperOS/updater
cp -f /home/Volumic/printer_data/config/.volumic/system/*.sh /home/Volumic/VyperOS
cp -f /home/Volumic/printer_data/config/.volumic/system/KlipperScreen.conf /home/Volumic/printer_data/config/KlipperScreen.conf
cp -f /home/Volumic/printer_data/config/.volumic/system/moonraker.env /home/Volumic/printer_data/systemd/moonraker.env
sudo chmod +x /home/Volumic/VyperOS/updater/*.sh
sudo chmod +x /home/Volumic/VyperOS/*.sh
# Base Moonraker : proprietaire Volumic, lecture/ecriture pour lui seul (plus de 666)
sudo chown Volumic:Volumic /home/Volumic/printer_data/database/moonraker-sql.db* 2>/dev/null || true
sudo chmod 644 /home/Volumic/printer_data/database/moonraker-sql.db* 2>/dev/null || true

# update repository list
sudo cp -f /home/Volumic/printer_data/config/.volumic/system/sources.list /etc/apt/

# Update system
sudo killall unattended-upgrades 2>/dev/null || true # Liberer les locks eventuels
while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
	sleep 2
done
# Mise a jour
sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq --fix-missing
# Finaliser
sudo dpkg --configure -a
sudo apt-get install -f -y
# Verifier que dpkg est vraiment fini
while sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1; do
	sleep 1
done
# update splash (ecran 5 pouces inverse des VS30 ULTRA Performance : theme inverse conserve)
sudo cp -f /home/Volumic/printer_data/config/.volumic/system/watermark.png /usr/share/plymouth/themes/armbian/
if grep -qE '^ks_angle="?inverted"?' /boot/system.cfg 2>/dev/null; then
	sudo bash /home/Volumic/printer_data/config/.volumic/system/ecran_ultra_perf.sh theme
else
	sudo plymouth-set-default-theme -R armbian
fi
# Timelapse (10/11/2026) : le composant Moonraker est un lien vers ~/moonraker-timelapse, supprime par le
# git clean des anciennes mises a jour (avertissement « section [timelapse] non analysee » ou timelapse absent).
# Recree le lien, ajoute la section [timelapse] a moonraker.conf si elle manque (timelapse desactive par defaut).
TL_SRC=/home/Volumic/moonraker-timelapse/component/timelapse.py
TL_DST=/home/Volumic/moonraker/moonraker/components/timelapse.py
TL_CONF=/home/Volumic/printer_data/config/moonraker.conf
if [ -f "$TL_SRC" ] && [ -d /home/Volumic/moonraker/moonraker/components ]; then
	TL_CHANGE=0
	if [ "$(readlink "$TL_DST")" != "$TL_SRC" ]; then
		sudo ln -sfn "$TL_SRC" "$TL_DST" && sudo chown -h Volumic:Volumic "$TL_DST" && TL_CHANGE=1
	fi
	if [ -f "$TL_CONF" ] && ! grep -q '^\[timelapse\]' "$TL_CONF"; then
		printf '\n[timelapse]\noutput_path: ~/timelapse/\nffmpeg_binary_path: /usr/bin/ffmpeg\nenabled: False\nparkhead: True\npark_travel_speed: 500\nautorender: True\n' | sudo tee -a "$TL_CONF" >/dev/null
		sudo chown Volumic:Volumic "$TL_CONF"; TL_CHANGE=1
	fi
	sudo mkdir -p /home/Volumic/timelapse && sudo chown Volumic:Volumic /home/Volumic/timelapse
	[ "$TL_CHANGE" = 1 ] && sudo systemctl restart moonraker
fi
}
