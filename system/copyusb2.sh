#!/bin/bash

HOST="127.0.0.1"
PORT="80"

DEVICE=sda1

# test that this device isn't already mounted
device_is_mounted=`grep ${DEVICE} /etc/mtab`
if [ -n "$device_is_mounted" ]; then
   echo "/dev/${DEVICE} is already mounted"
fi

eval `/sbin/blkid -o export /dev/${DEVICE}` # pull in useful variables from vol_id
DIR=`mktemp -d`
systemd-mount -o ro --automount=yes --collect /dev/${DEVICE} ${DIR} 
curl --header "Content-Type: application/json"   --request POST --data '{"commands":["M117 Démarrage de la copie des fichiers USB"] }'   "http://${HOST}:${PORT}/api/printer/command"
shopt -s nocaseglob
for file in ${DIR}/*.{gcode,gc}
do
    [ -e "${file}" ] || continue
    echo "uploading ${file}"
    curl -F "file=@${file}" -F "root"="gcodes" "http://${HOST}:${PORT}/server/files/upload"
done
systemd-umount ${DIR}
rmdir ${DIR}
curl --header "Content-Type: application/json"   --request POST --data '{"commands":["M117 Fichiers USB copiés"] }'   "http://${HOST}:${PORT}/api/printer/command"
