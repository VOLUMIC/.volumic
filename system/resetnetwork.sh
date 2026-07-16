#!/bin/bash

hexchars="0123456789abcdef"
end=$( for i in {1..6} ; do echo -n ${hexchars:$(( $RANDOM % 16 )):1} ; done | sed -e 's/\(..\)/:\1/g' )
sudo cp /home/Volumic/printer_data/config/.volumic/system/interfaces /etc/network/interfaces
sudo cp /home/Volumic/printer_data/config/.volumic/system/interfaces /etc/network/interfaces.default
sudo sed -i "s/:00:00:00/$end/g" /etc/network/interfaces.default
sudo sed -i "s/:00:00:00/$end/g" /etc/network/interfaces
sudo reboot