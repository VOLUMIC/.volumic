#!/bin/bash
{
printf "\033[2J\033[H\033[?25l" > /dev/tty1
echo " " > /dev/tty1
echo "  VyperOS starting..." > /dev/tty1
sleep 1

sudo chown Volumic:Volumic /home/Volumic/ -R
cd /home/Volumic/printer_data/gcodes
if [ ! -d "SecureMemory" ]; then
  mkdir SecureMemory
  sudo chmod -R -v 776 SecureMemory
  sudo rmdir SecureMemory/lost+found --ignore-fail-on-non-empty
fi
sync

cd /boot/scripts

#./initmmc.sh

#./extend_fs.sh

#./genmac.sh

./system_cfg.sh

sync

cd /home/Volumic/printer_data/config/.volumic/system/
sudo chmod +x *.sh
./system.sh
}