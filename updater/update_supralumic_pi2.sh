sudo service klipper stop
cd ~/klipper
git pull
make KCONFIG_CONFIG=updater/config.supralumic
make KCONFIG_CONFIG=updater/config.supralumic flash FLASH_DEVICE=/dev/serial/by-path/platform-fd840000.usb-usb-0:1:1.0
sudo service klipper start
