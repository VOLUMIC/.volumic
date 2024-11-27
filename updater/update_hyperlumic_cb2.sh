sudo service klipper stop
cd ~/klipper
git pull
make KCONFIG_CONFIG=updater/config.hyperlumic
make KCONFIG_CONFIG=updater/config.hyperlumic flash FLASH_DEVICE=/dev/serial/by-path/platform-xhci-hcd.4.auto-usb-0:1.4:1.0
sudo service klipper start
