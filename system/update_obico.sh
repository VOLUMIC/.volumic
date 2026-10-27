#!/bin/bash
{
if [ "$(id -u)" = "0" ]; then
    export HOME=/root
fi
export GIT_CONFIG_GLOBAL="${HOME}/.gitconfig"
git config --global --replace-all safe.directory '*'
git config --global pull.rebase false

OBICO=/home/Volumic/moonraker-obico
OBICO_ENV=/home/Volumic/moonraker-obico-env

ping -q -c 2 -W 3 8.8.8.8 >/dev/null 2>&1	# test if internet is connected
if [ $? -eq 0 ] && [ -d "$OBICO/.git" ]; then	# internet connected et Obico installe

	# Update Obico (pas de git clean : le dossier contient des fichiers d'execution ignores par git)
	cd "$OBICO"
	git reset --hard
	git pull
	# Dependances Python d'Obico dans son environnement
	if [ -x "$OBICO_ENV/bin/pip" ] && [ -f "$OBICO/requirements.txt" ]; then
		"$OBICO_ENV/bin/pip" install -q -r "$OBICO/requirements.txt"
	fi
	# Les fichiers restent a l'utilisateur Volumic (le script tourne en root)
	chown -R Volumic:Volumic "$OBICO" "$OBICO_ENV" 2>/dev/null || true
	sleep 1
	sudo service moonraker-obico restart

fi
}
