#!/bin/bash

cd ~
git clone https://github.com/shiftingtech/Moonraker-loader.git
sudo cp /home/Volumic/printer_data/config/.volumic/system/moonraker-loader.sh /home/Volumic/Moonraker-loader/assets/
sudo chmod +x /home/Volumic/Moonraker-loader/assets/*.sh
sudo ln -sf ~/Moonraker-loader/assets/89-moonraker-loader.rules /etc/udev/rules.d
sudo ln -sf ~/Moonraker-loader/assets/*.sh /usr/local/sbin
reboot
