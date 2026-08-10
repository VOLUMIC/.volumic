#!/bin/bash
{
sudo plymouth quit 2>/dev/null || true
printf "\033[2J\033[H\033[?25l" > /dev/tty1
echo " " > /dev/tty1
echo "  VyperOS Configuration" > /dev/tty1
echo "  ---------------------" > /dev/tty1
echo " " > /dev/tty1
echo " -> First boot partition expand, please wait" > /dev/tty1

c=0
cd /dev
for file in `ls mmcblk*`
do
    filelist[$c]=$file
    echo "${filelist[$c]}"
    ((c++))
done

ROOT_DEV=/dev/${filelist[0]}

BOOT_NUM=1
ROOT_NUM=2

ROOTFS_START=557056

# fdisk
sudo fdisk "$ROOT_DEV" << EOF
p
d
$ROOT_NUM
n
p
$ROOT_NUM
$ROOTFS_START

w
EOF

echo " -> Resizing..." > /dev/tty1
sudo resize2fs /dev/${filelist[0]}p${ROOT_NUM}
unset filelist
sudo sed -i '/^.\/extend_fs.sh/s/^/#/' /boot/scripts/btt_init.sh
echo " -> Finished, continuing..." > /dev/tty1
}