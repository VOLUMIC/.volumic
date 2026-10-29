#!/bin/bash
# Migration 002 (29/10/2026) : reglages repris des scripts de mise a jour (regle : les
# modifications de fichiers hors .volumic passent par system_update.sh)
# - moonraker.conf : max_upload_size: 4096 apres "port: 7125" s'il est absent
# - dossier printer_data/tmp
CONF=/home/Volumic/printer_data/config/moonraker.conf
if [ -f "$CONF" ] && ! grep -q "max_upload_size" "$CONF" && grep -q "port: 7125" "$CONF"; then
	cp -f "$CONF" "$CONF.avant_002" || exit 1
	sed -i "/port: 7125/a max_upload_size: 4096" "$CONF"
	chown Volumic:Volumic "$CONF" "$CONF.avant_002"
fi
mkdir -p /home/Volumic/printer_data/tmp && chown Volumic:Volumic /home/Volumic/printer_data/tmp
