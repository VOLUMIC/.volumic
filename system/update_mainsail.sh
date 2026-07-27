#!/bin/bash
{
ping -q -c 2 -W 3 8.8.8.8 >/dev/null 2>&1	# test if internet is connected
if [ $? -eq 0 ]; then	# internet connected

	# Update mainsail
	cd /home/Volumic/mainsail
	rm -R -f ./*
	rm .version
	wget -q -O mainsail.zip https://github.com/mainsail-crew/mainsail/releases/latest/download/mainsail.zip && unzip mainsail.zip && rm mainsail.zip

fi
}
