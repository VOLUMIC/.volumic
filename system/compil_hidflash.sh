#!/bin/bash

cd ~/klipper/lib/hidflash
make
sudo cp /home/Volumic/printer_data/config/.volumic/system/99-stm32_hid_bl.rules /etc/udev/rules.d
reboot
