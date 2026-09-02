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

	# Update KlipperScreen
	cd /home/Volumic/KlipperScreen
	git reset --hard
	git clean -fd
	git pull
	sleep 1
	sudo service KlipperScreen restart

fi
}
