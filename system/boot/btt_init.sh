#!/bin/bash
# =============================================================================
# VyperOS - demarrage (lance par /etc/rc.local)
# Installe dans /boot/scripts par system_update.sh (system_files.list) :
# ne pas modifier sur les machines, modifier .volumic/system/boot/btt_init.sh
# =============================================================================
{
printf "\033[2J\033[H\033[?25l" > /dev/tty1
echo " " > /dev/tty1
echo "  VyperOS starting..." > /dev/tty1

# Droits : ne corrige que les fichiers qui n'appartiennent pas a Volumic
# (avant : chown -R de tout /home/Volumic a chaque demarrage, ~21 000 ecritures)
find /home/Volumic \( ! -user Volumic -o ! -group Volumic \) -exec chown -h Volumic:Volumic {} + 2>/dev/null

cd /home/Volumic/printer_data/gcodes
if [ ! -d "SecureMemory" ]; then
  mkdir SecureMemory
  chmod -R 776 SecureMemory
  rmdir SecureMemory/lost+found --ignore-fail-on-non-empty
fi
sync

cd /boot/scripts

#./extend_fs.sh

#./genmac.sh

./system_cfg.sh &

# regular sync to prevent data loss when direct power outage
./sync.sh &

# Configuration et mises a jour systeme VyperOS (lance par bash : pas besoin du droit d'execution)
bash /home/Volumic/printer_data/config/.volumic/system/system.sh
}
