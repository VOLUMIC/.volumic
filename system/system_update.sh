#!/bin/bash
# =============================================================================
# VyperOS - mise a jour systeme, lancee au demarrage par system.sh (en root)
#   system_update.sh          : complet (apres une mise a jour complete, repere sys1 absent)
#                               fichiers systeme + migrations + paquets apt
#   system_update.sh --files  : fichiers systeme + migrations seulement
#                               (au demarrage qui suit une nouvelle version du depot)
# REGLE : tout fichier systeme hors ~/VyperOS et .volumic est installe ici,
# via system_files.list (fichiers communs) ou system/migrations/ (fichiers propres
# a chaque machine). Jamais de modification a la main sur les machines.
# =============================================================================
{
SYS=/home/Volumic/printer_data/config/.volumic/system
VY=/home/Volumic/VyperOS
FILES_ONLY=0
[ "$1" = "--files" ] && FILES_ONLY=1
echo "=== system_update.sh $(date '+%F %T') ${1:-complet}"

# --- 1) Fichiers systeme communs (system_files.list) -------------------------
trim() {
	local v="$1"
	v="${v#"${v%%[![:space:]]*}"}"
	v="${v%"${v##*[![:space:]]}"}"
	printf '%s' "$v"
}
install_system_files() {
	local list="$SYS/system_files.list" src dst mode owner post tmp changed=""
	[ -f "$list" ] || return 0
	while IFS='|' read -r src dst mode owner post; do
		src=$(trim "$src")
		case "$src" in ""|\#*) continue ;; esac
		dst=$(trim "$dst"); mode=$(trim "$mode"); owner=$(trim "$owner"); post=$(trim "$post")
		if [ ! -f "$SYS/$src" ]; then echo "  absent du depot : $src"; continue; fi
		if [ -f "$dst" ] && cmp -s "$SYS/$src" "$dst"; then continue; fi
		if [ "$post" = "sudoers" ] && ! visudo -cf "$SYS/$src" >/dev/null 2>&1; then
			echo "  REFUSE (sudoers invalide) : $src"; continue
		fi
		mkdir -p "$(dirname "$dst")"
		tmp="$dst.vyperos_new"
		if cp -f "$SYS/$src" "$tmp"; then
			[ -n "$mode" ] && chmod "$mode" "$tmp" 2>/dev/null
			[ -n "$owner" ] && chown "$owner" "$tmp" 2>/dev/null
			mv -f "$tmp" "$dst" && echo "  installe : $dst"
			case " $changed " in *" $post "*) ;; *) changed="$changed $post" ;; esac
		else
			rm -f "$tmp"; echo "  ECHEC copie : $dst"
		fi
	done < "$list"
	for post in $changed; do
		case "$post" in
			udev) udevadm control --reload-rules && udevadm trigger ;;
			plymouth) plymouth-set-default-theme -R armbian ;;
			systemd) systemctl daemon-reload ;;
		esac
	done
}

# --- 2) Migrations (system/migrations/NNN_*.sh, une seule fois par machine) --
run_migrations() {
	local done_file="$VY/.migrations_done" m name
	touch "$done_file"
	for m in "$SYS"/migrations/[0-9]*.sh; do
		[ -f "$m" ] || continue
		name=$(basename "$m")
		grep -qxF "$name" "$done_file" && continue
		if bash "$m"; then
			echo "$name" >> "$done_file"; echo "  migration faite : $name"
		else
			echo "  migration en ECHEC : $name (relancee au prochain demarrage)"
		fi
	done
}

install_system_files
run_migrations

# --- 3) Copies d'execution VyperOS et reglages ------------------------------
cp -u -f /home/Volumic/printer_data/config/.volumic/updater/*.* /home/Volumic/VyperOS/updater
cp -f /home/Volumic/printer_data/config/.volumic/system/*.sh /home/Volumic/VyperOS
HKS=/home/Volumic/VyperOS/ksconf_merge.sh; [ -f "$HKS" ] || HKS=/home/Volumic/printer_data/config/.volumic/system/ksconf_merge.sh; bash "$HKS"  # KlipperScreen.conf : menus du depot + reglages client conserves
sudo chmod +x /home/Volumic/VyperOS/updater/*.sh
sudo chmod +x /home/Volumic/VyperOS/*.sh
# Base Moonraker : proprietaire Volumic, lecture/ecriture pour lui seul (plus de 666)
sudo chown Volumic:Volumic /home/Volumic/printer_data/database/moonraker-sql.db* 2>/dev/null || true
sudo chmod 644 /home/Volumic/printer_data/database/moonraker-sql.db* 2>/dev/null || true

# --- 4) Paquets systeme (seulement apres une mise a jour complete) ---------
if [ $FILES_ONLY -eq 1 ]; then
	echo "=== fin (fichiers seulement)"
	exit 0
fi
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
echo "=== fin"
}
