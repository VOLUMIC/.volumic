sudo service klipper stop
cd ~/klipper
git pull
make KCONFIG_CONFIG=updater/config.hyperlumic
make KCONFIG_CONFIG=updater/config.hyperlumic flash FLASH_DEVICE=/dev/serial/by-path/platform-5200000.usb-usb-0:1.3:1.0
sudo service klipper start
