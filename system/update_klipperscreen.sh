#!/bin/bash
{
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
