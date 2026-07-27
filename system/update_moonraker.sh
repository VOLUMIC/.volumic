#!/bin/bash

ping -q -c 2 -W 3 8.8.8.8 >/dev/null 2>&1	# test if internet is connected
if [ $? -eq 0 ]; then	# internet connected

	sudo service moonraker stop
	# Update Moonraker
	cd /home/Volumic/moonraker
	git pull
	sleep 2
	sudo service moonraker start

fi
