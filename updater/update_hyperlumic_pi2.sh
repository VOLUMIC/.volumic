sudo service klipper stop
cd ~/klipper
git pull
make clean KCONFIG_CONFIG=~/printer_data/config/.volumic/updater/config.hyperlumic
make KCONFIG_CONFIG=~/printer_data/config/.volumic/updater/config.hyperlumic
make KCONFIG_CONFIG=~/printer_data/config/.volumic/updater/config.hyperlumic flash FLASH_DEVICE=/dev/serial/by-path/platform-fd840000.usb-usb-0:1:1.0
sudo service klipper start
