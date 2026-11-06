#!/bin/bash
# =============================================================================
# VyperOS - mise a jour du bootloader HID des cartes Hyperlumic (STM32H723)
#   bash bootloader_hyperlumic.sh          (appele par vyperos_update.sh, branche Hyperlumic)
#   bash bootloader_hyperlumic.sh resume   (appele au demarrage par system.sh si une
#                                           ecriture a ete interrompue)
# Securites :
#  - une seule fois par machine : repere ~/VyperOS/BL3 cree seulement si le bootloader
#    a ete ecrit ET relu identique
#  - image verifiee (SHA-256) et controlee (bootloader STM32H723) avant toute ecriture
#  - seule la carte Hyperlumic est visee (port USB fixe + controle STM32H723)
#  - la puce garde son bootloader d'usine (ROM DFU, ineffacable) : si une ecriture echoue,
#    la carte reste en mode DFU tant qu'elle est alimentee et l'ecriture est relancee
#    automatiquement jusqu'a reussite (WRITE_ROUNDS tentatives, chacune relue)
#  - repere ~/VyperOS/.bootloader_en_cours pendant l'operation : si l'ecriture n'a pas
#    abouti, la machine redemarre (la carte reste alimentee, donc en DFU) et l'ecriture
#    reprend au demarrage suivant (MAX_BOOT_RESUMES demarrages au plus)
#  - journal : ~/VyperOS/bootloader.log
# Codes de sortie : 0 fait ou rien a faire, 1 non fait (rien n'a ete modifie),
#                   3 echec apres toutes les tentatives (carte en DFU, support)
# =============================================================================
SYS=/home/Volumic/printer_data/config/.volumic/system
VY=/home/Volumic/VyperOS
BIN="$SYS/hyperlumic_bootloader_v2.bin"
PY="$SYS/update_bootloader.py"
SHA256=216c90b23a654bf41af9be99b1a718abb2b1cf1b5300b926107ee18f48e692b2
SERIAL=/dev/serial/by-path/platform-fd840000.usb-usb-0:1:1.0
INPROGRESS="$VY/.bootloader_en_cours"
LOG="$VY/bootloader.log"
WRITE_ROUNDS=10
MAX_BOOT_RESUMES=3
MODE="${1:-update}"

say() { echo "$*"; echo "[$(date '+%F %T')] $*" >> "$LOG"; }
tty_msg() {   # message visible sur l'ecran pendant l'operation
	printf "\033[2J\033[H\n   VyperOS\n   -------\n\n   %s\n\n   Ne pas eteindre la machine pendant cette operation.\n" "$1" > /dev/tty1 2>/dev/null
}
dfu_port() {  # port USB d'une carte en mode ROM DFU (0483:df11), vide sinon
	for d in /sys/bus/usb/devices/*; do
		case "$(basename "$d")" in *:*) continue ;; esac
		[ "$(cat "$d/idVendor" 2>/dev/null):$(cat "$d/idProduct" 2>/dev/null)" = "0483:df11" ] && { basename "$d"; return; }
	done
}
done_ok() {
	mkdir -p "$VY/BL3"
	rm -f "$INPROGRESS"
	touch /tmp/vyperos_bootloader_flashed
	say "Bootloader v2 : installe et verifie"
	if [ "$MODE" = "resume" ]; then
		# Reprise au demarrage : si Klipper ne revient pas, le reflasher puis le relancer
		for i in $(seq 1 15); do [ -e "$SERIAL" ] && break; sleep 1; done
		if [ ! -e "$SERIAL" ] && [ -f /home/Volumic/klipper/out/klipper.bin ]; then
			HFS="$VY/hidflash_safe.sh"; [ -f "$HFS" ] || HFS="$SYS/hidflash_safe.sh"
			say "Bootloader v2 : flash de Klipper apres reprise"
			bash "$HFS" /home/Volumic/klipper/out/klipper.bin serial/by-path/platform-fd840000.usb-usb-0:1:1.0 >> "$LOG" 2>&1
		fi
		systemctl restart klipper 2>/dev/null
		printf "\033[2J\033[H" > /dev/tty1 2>/dev/null
	fi
	exit 0
}

if [ "$MODE" = "resume" ]; then
	[ -f "$INPROGRESS" ] || exit 0
	BOOTS=$(( $(cat "$INPROGRESS" 2>/dev/null || echo 0) + 1 ))
	if [ "$BOOTS" -gt "$MAX_BOOT_RESUMES" ]; then
		say "Bootloader v2 : echec apres $MAX_BOOT_RESUMES reprises au demarrage - support VOLUMIC"
		tty_msg "Mise a jour de la carte electronique non terminee : contactez le support VOLUMIC."
		exit 3
	fi
	echo "$BOOTS" > "$INPROGRESS"
	say "Bootloader v2 : reprise d'une ecriture interrompue (demarrage $BOOTS/$MAX_BOOT_RESUMES)"
	systemctl stop klipper 2>/dev/null
elif [ -d "$VY/BL3" ]; then
	say "Bootloader v2 : deja installe"; exit 0
fi

# --- Controles avant toute ecriture (aucun risque s'ils echouent) ---
if [ ! -f "$BIN" ] || [ ! -f "$PY" ]; then say "Bootloader v2 : fichiers absents du depot, ignore"; exit 1; fi
if [ "$(sha256sum "$BIN" | cut -d' ' -f1)" != "$SHA256" ]; then
	say "Bootloader v2 : image differente de la version validee, ignore"; exit 1
fi
if ! which dfu-util >/dev/null 2>&1; then
	say "Bootloader v2 : installation de dfu-util"
	apt-get install -y -qq dfu-util >/dev/null 2>&1
fi
which dfu-util >/dev/null 2>&1 || { say "Bootloader v2 : dfu-util indisponible (hors ligne ?), ignore"; exit 1; }

PORT=$(dfu_port)
if [ -z "$PORT" ] && [ ! -e "$SERIAL" ]; then
	say "Bootloader v2 : carte Hyperlumic introuvable, ignore"
	[ "$MODE" = "resume" ] && say "Bootloader v2 : carte ni en Klipper ni en DFU (alimentation coupee pendant l'ecriture ?) - procedure support : bouton BOOT"
	exit 1
fi

# --- Ecriture : premiere tentative depuis Klipper, puis reprises tant que la carte est en DFU ---
[ -f "$INPROGRESS" ] || echo 0 > "$INPROGRESS"
tty_msg "Mise a jour de la carte electronique en cours..."
for round in $(seq 1 $WRITE_ROUNDS); do
	PORT=$(dfu_port)
	if [ -n "$PORT" ]; then
		say "Bootloader v2 : ecriture (carte en DFU sur $PORT), tentative $round/$WRITE_ROUNDS"
		python3 "$PY" "$BIN" --sha256 "$SHA256" --usb-port "$PORT" --yes >> "$LOG" 2>&1
	elif [ -e "$SERIAL" ]; then
		say "Bootloader v2 : ecriture (carte sous Klipper), tentative $round/$WRITE_ROUNDS"
		python3 "$PY" "$BIN" --sha256 "$SHA256" --serial "$SERIAL" --yes >> "$LOG" 2>&1
	else
		say "Bootloader v2 : carte absente, attente"; sleep 5; continue
	fi
	RC=$?
	case $RC in
		0|4) done_ok ;;   # 4 = ecrit et relu, Klipper sera reflashe juste apres
		1|2)
			# Rien n'a ete ecrit : la carte garde son ancien bootloader
			if [ -z "$(dfu_port)" ]; then
				rm -f "$INPROGRESS"
				say "Bootloader v2 : non installe (code $RC), rien n'a ete modifie ; nouvel essai a la prochaine mise a jour"
				exit 1
			fi ;;
		3) say "Bootloader v2 : ecriture non verifiee (code 3), nouvelle tentative" ;;
	esac
	tty_msg "Mise a jour de la carte electronique : nouvelle tentative ($round/$WRITE_ROUNDS)..."
	sleep 5
done

say "Bootloader v2 : ECHEC apres $WRITE_ROUNDS tentatives - carte maintenue en DFU, reprise au prochain demarrage"
exit 3
