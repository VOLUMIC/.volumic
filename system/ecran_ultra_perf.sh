#!/bin/bash
# =============================================================================
# VyperOS - VS30 ULTRA passee en Performance : ecran 5 pouces monte a l'envers
# par rapport aux ecrans 7 pouces des autres modeles.
# A lancer UNE SEULE FOIS apres l'upgrade (depuis SSH) :
#     sudo bash /home/Volumic/VyperOS/ecran_ultra_perf.sh
# Retour a l'affichage normal :
#     sudo bash /home/Volumic/VyperOS/ecran_ultra_perf.sh normal
# Ce qui est retourne :
#  - KlipperScreen (affichage + tactile) : /boot/system.cfg (ks_src / ks_angle),
#    applique par /boot/scripts/system_cfg.sh a chaque demarrage
#  - ecran de demarrage (logo VOLUMIC + animation) : theme plymouth "volumic-inverse"
#    (images du theme armbian tournees de 180 degres, positions inversees)
#  - logo u-boot (/boot/boot.bmp) et textes de la console : fbcon=rotate:2
# Mode interne "theme" : regenere seulement le theme inverse (appele par
# system_update.sh quand le logo de demarrage change).
# =============================================================================
MODE="${1:-inverted}"
case "$MODE" in normal|inverted|theme) ;; *) echo "Usage : $0 [inverted|normal]"; exit 2 ;; esac
if [ "$(id -u)" != "0" ]; then echo "A lancer avec sudo"; exit 1; fi
CFG=/boot/system.cfg
ENV=/boot/armbianEnv.txt
THEMES=/usr/share/plymouth/themes
INV=volumic-inverse

# --- Theme plymouth inverse (images tournees de 180 degres, positions miroir) ---
build_theme() {
	python3 - "$THEMES/armbian" "$THEMES/$INV" <<'PYEOF'
import os, re, sys
from PIL import Image
src, dst = sys.argv[1], sys.argv[2]
os.makedirs(dst, exist_ok=True)
for f in os.listdir(src):
    if f.lower().endswith(".png"):
        im = Image.open(os.path.join(src, f))
        im.rotate(180).save(os.path.join(dst, f))
conf = open(os.path.join(src, "armbian.plymouth"), encoding="utf-8").read()
conf = conf.replace("Name=Armbian", "Name=VOLUMIC inverse").replace("ImageDir=" + src, "ImageDir=" + dst)
def mirror(m):
    return "%s=%s" % (m.group(1), ("%.3f" % (1 - float(m.group(2)))).rstrip("0").rstrip("."))
conf = re.sub(r"^((?:Dialog|Title|Watermark)?VerticalAlignment)=([0-9.]+)", mirror, conf, flags=re.M)
conf = re.sub(r"^((?:Dialog|Title|Watermark)?HorizontalAlignment)=([0-9.]+)", mirror, conf, flags=re.M)
conf = re.sub(r"^(Watermark[XY]Offset)=(-?[0-9]+)", lambda m: "%s=%d" % (m.group(1), -int(m.group(2))), conf, flags=re.M)
conf = conf.replace("MessageBelowAnimation=true", "MessageBelowAnimation=false")
open(os.path.join(dst, os.path.basename(dst) + ".plymouth"), "w", encoding="utf-8").write(conf)
PYEOF
}

# --- Logo u-boot : rotation de 180 degres (sauvegarde boot.bmp.normal) ---
rotate_bootlogo() {
	local want="$1"
	[ -f /boot/boot.bmp ] || return 0
	[ -f /boot/boot.bmp.normal ] || cp -f /boot/boot.bmp /boot/boot.bmp.normal
	if [ "$want" = "inverted" ]; then
		python3 -c "from PIL import Image; im=Image.open('/boot/boot.bmp.normal'); im.rotate(180).save('/boot/boot.bmp', format='BMP')"
	else
		cp -f /boot/boot.bmp.normal /boot/boot.bmp
	fi
}

if [ "$MODE" = "theme" ]; then
	build_theme && plymouth-set-default-theme -R "$INV"
	exit $?
fi

# --- KlipperScreen : system.cfg + system_cfg.sh ---
CUR_OUT=$(DISPLAY=:0 XAUTHORITY=/home/Volumic/.Xauthority xrandr --query 2>/dev/null | awk '/ connected/ {print $1; exit}')
[ -n "$CUR_OUT" ] || CUR_OUT=$(grep -E '^ks_src=' "$CFG" | cut -d= -f2 | tr -d '"\r')
[ -n "$CUR_OUT" ] || CUR_OUT="HDMI-1"
echo "Ecran : $CUR_OUT -> $MODE"
[ -f "$CFG.avant_rotation" ] || cp -f "$CFG" "$CFG.avant_rotation"
for kv in "ks_src=\"$CUR_OUT\"" "ks_angle=\"$MODE\""; do
	key="${kv%%=*}"
	if grep -qE "^[[:space:]]*#?[[:space:]]*${key}=" "$CFG"; then
		sed -i -E "s|^[[:space:]]*#?[[:space:]]*${key}=.*|${kv}|" "$CFG"
	else
		printf '%s\n' "$kv" >> "$CFG"
	fi
done

# --- Console (textes de demarrage et de mise a jour) : fbcon=rotate:2 ---
[ -f "$ENV.avant_rotation" ] || cp -f "$ENV" "$ENV.avant_rotation"
sed -i -E 's/[[:space:]]*fbcon=rotate:[0-3]//' "$ENV"
if [ "$MODE" = "inverted" ]; then
	if grep -q '^extraargs=' "$ENV"; then
		sed -i -E 's/^extraargs=(.*)$/extraargs=\1 fbcon=rotate:2/; s/^extraargs= /extraargs=/' "$ENV"
	else
		echo "extraargs=fbcon=rotate:2" >> "$ENV"
	fi
fi
sed -i -E '/^extraargs=[[:space:]]*$/d' "$ENV"

# --- Ecran de demarrage et logo u-boot ---
rotate_bootlogo "$MODE"
if [ "$MODE" = "inverted" ]; then
	build_theme && plymouth-set-default-theme -R "$INV"
else
	plymouth-set-default-theme -R armbian
fi

grep -E '^ks_(src|angle)=' "$CFG"; grep -E '^extraargs=' "$ENV"; echo "Theme de demarrage : $(plymouth-set-default-theme)"

# Application immediate pour KlipperScreen (le reste au prochain demarrage)
bash /boot/scripts/system_cfg.sh
echo "Termine : KlipperScreen est en position $MODE ; ecran de demarrage au prochain redemarrage."
