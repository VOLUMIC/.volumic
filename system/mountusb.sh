#!/bin/bash

sleep 1
cd /home/Volumic/printer_data/gcodes

if ! [ -d "USB" ]; then
  mkdir USB
fi

sleep 2
if ! systemd-mount -o ro --automount=yes --collect /dev/sda1 /home/Volumic/printer_data/gcodes/USB ; then
  echo Error mounting disk
  rmdir USB
fi
