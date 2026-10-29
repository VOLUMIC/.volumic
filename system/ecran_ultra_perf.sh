#!/bin/bash
# =============================================================================
# VyperOS - VS30 ULTRA passee en Performance : ecran 5 pouces monte a l'envers
# par rapport aux ecrans 7 pouces des autres modeles.
# A lancer UNE SEULE FOIS apres l'upgrade (depuis SSH) :
#     sudo bash /home/Volumic/VyperOS/ecran_ultra_perf.sh
# Retour a l'affichage normal :
#     sudo bash /home/Volumic/VyperOS/ecran_ultra_perf.sh normal
# Le reglage est ecrit dans /boot/system.cfg (ks_src / ks_angle) et applique par
# /boot/scripts/system_cfg.sh (affichage + tactile), y compris aux demarrages suivants.
# =============================================================================
ANGLE="${1:-inverted}"
case "$ANGLE" in normal|inverted) ;; *) echo "Usage : $0 [inverted|normal]"; exit 2 ;; esac
if [ "$(id -u)" != "0" ]; then echo "A lancer avec sudo"; exit 1; fi
CFG=/boot/system.cfg
[ -f "$CFG" ] || { echo "$CFG introuvable"; exit 1; }

# Sortie video utilisee (nom attendu par X pour la rotation)
OUT=$(DISPLAY=:0 XAUTHORITY=/home/Volumic/.Xauthority xrandr --query 2>/dev/null | awk '/ connected/ {print $1; exit}')
if [ -z "$OUT" ]; then
	OUT=$(grep -E '^ks_src=' "$CFG" | cut -d= -f2 | tr -d '"\r')
fi
[ -n "$OUT" ] || OUT="HDMI-1"
echo "Ecran : $OUT -> $ANGLE"

[ -f "$CFG.avant_rotation" ] || cp -f "$CFG" "$CFG.avant_rotation"
for kv in "ks_src=\"$OUT\"" "ks_angle=\"$ANGLE\""; do
	key="${kv%%=*}"
	if grep -qE "^[[:space:]]*#?[[:space:]]*${key}=" "$CFG"; then
		sed -i -E "s|^[[:space:]]*#?[[:space:]]*${key}=.*|${kv}|" "$CFG"
	else
		printf '%s\n' "$kv" >> "$CFG"
	fi
done
grep -E '^ks_(src|angle)=' "$CFG"

# Application immediate (redemarre l'affichage si besoin)
bash /boot/scripts/system_cfg.sh
echo "Termine : l'ecran redemarre en position $ANGLE."
