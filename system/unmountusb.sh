#!/bin/bash

if ! systemd-umount /home/Volumic/printer_data/gcodes/USB ; then
  echo Error unmounting disk
fi

cd /home/Volumic/printer_data/gcodes
if [ -d "USB" ]; then
  rmdir USB
fi
