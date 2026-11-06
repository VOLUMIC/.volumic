#!/bin/bash
# =============================================================================
# VyperOS - lance a chaque demarrage par /boot/scripts/btt_init.sh (en root)
# - met a jour les copies d'execution des scripts dans ~/VyperOS
# - reprend une ecriture du bootloader Hyperlumic interrompue (.bootloader_en_cours)
# - lance system_update.sh :
#     complet          apres une mise a jour complete (repere sys1 absent)
#     --files          si les fichiers systeme du depot ont change depuis le
#                      dernier demarrage (y compris mise a jour par Moonraker)
# =============================================================================
{
SYS=/home/Volumic/printer_data/config/.volumic/system
VY=/home/Volumic/VyperOS
mkdir -p "$VY/updater"

# Copies d'execution (les scripts sont lances depuis ~/VyperOS)
cp -f "$SYS"/*.sh "$VY"/
chmod 755 "$VY"/*.sh
chown Volumic:Volumic "$VY" "$VY"/*.sh "$VY/updater" 2>/dev/null

# Empreinte des fichiers systeme du depot (liste + fichiers listes + migrations)
cd "$SYS" || exit 1
VERSION=$( { cat system_files.list
	awk -F'|' '!/^[[:space:]]*#/ && NF > 1 { gsub(/[[:space:]]/, "", $1); print $1 }' system_files.list | while read -r f; do cat "$f" 2>/dev/null; done
	cat migrations/*.sh 2>/dev/null; } | md5sum | cut -d' ' -f1 )

cd "$VY" || exit 1

# Ecriture du bootloader Hyperlumic interrompue : reprise avant tout le reste
[ -f "$VY/.bootloader_en_cours" ] && bash "$VY/bootloader_hyperlumic.sh" resume

if [ ! -d "sys1" ]; then
	mkdir sys1
	bash "$VY/system_update.sh" > lastsysupdate.log 2>&1
	echo "$VERSION" > .system_version
elif [ "$VERSION" != "$(cat .system_version 2>/dev/null)" ]; then
	bash "$VY/system_update.sh" --files > lastsysfiles.log 2>&1
	echo "$VERSION" > .system_version
fi

# Ecran 5 pouces inverse (VS30 ULTRA Performance) : remet a chaque demarrage ce qu'une
# mise a jour aurait annule (theme de demarrage, logo u-boot, console). Sans effet sur
# les autres machines (ks_angle="inverted" absent de /boot/system.cfg).
bash "$SYS/ecran_ultra_perf.sh" verifier
}
