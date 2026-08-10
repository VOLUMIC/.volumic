#!/bin/bash

echo "" > /dev/tty1
echo "" > /dev/tty1
printf "\033[2J\033[H" > /dev/tty1
systemctl stop moonraker 2>/dev/null || true
systemctl stop KlipperScreen 2>/dev/null || true
systemctl stop klipper 2>/dev/null || true
sync
plymouth quit 2>/dev/null || true

echo "" > /dev/tty1
echo "" > /dev/tty1
printf "\033[2J\033[H" > /dev/tty1
echo " " > /dev/tty1
echo " " > /dev/tty1
echo " " > /dev/tty1
echo " " > /dev/tty1
echo " " > /dev/tty1
echo "                                                       VOLUMIC VyperOS" > /dev/tty1
echo "                                                       ---------------" > /dev/tty1
echo " " > /dev/tty1
echo " " > /dev/tty1
echo " " > /dev/tty1
echo " " > /dev/tty1
echo "                       Vous pouvez maintenant éteindre votre imprimante 3D VOLUMIC en toute sécurité." > /dev/tty1
echo " " > /dev/tty1

while true; do
	sync
	sleep 30
done
