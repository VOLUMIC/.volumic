sudo service klipper stop
cd ~/klipper
git pull
make KCONFIG_CONFIG=updater/config.acc
make KCONFIG_CONFIG=updater/config.acc flash FLASH_DEVICE=/dev/serial/by-path/platform-fd8c0000.usb-usb-0:1:1.0
sudo service klipper start
