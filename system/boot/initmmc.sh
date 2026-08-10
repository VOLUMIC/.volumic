#!/bin/bash
{
sudo plymouth quit 2>/dev/null || true
printf "\033[2J\033[H" > /dev/tty3
echo " " > /dev/tty1
echo " -> VOLUMIC VyperOS system first boot" > /dev/tty1
echo " ------------------------------------" > /dev/tty1
echo " " > /dev/tty1

echo " -> Disable MMC" > /dev/tty1
sudo umount /dev/mmcblk1

echo " -> Partitionning MMC" > /dev/tty1
sudo mkfs -t ext4 /dev/mmcblk1 << EOF
y
EOF

echo " -> Mounting MMC" > /dev/tty1
sync
sudo mount /dev/mmcblk1 /home/Volumic/printer_data/gcodes/SecureMemory
sync

echo " -> Configuring MMC" > /dev/tty1
cd /home/Volumic/printer_data/gcodes
sudo chown Volumic:Volumic /home/Volumic/ -R
sudo chmod -R -v 776 SecureMemory
sudo rmdir SecureMemory/lost+found --ignore-fail-on-non-empty
sync

echo " -> Unmounting MMC" > /dev/tty1
sudo umount /dev/mmcblk1

echo " -> System configuration" > /dev/tty1
cd /boot/scripts
sudo sed -i '/^.\/initmmc.sh/s/^/#/' /boot/scripts/btt_init.sh
sync

echo " -> Rebooting..." > /dev/tty1
sleep 5
sudo reboot
}
