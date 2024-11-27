cd ~/printer_data/config/.volumic/updater/
make KCONFIG_CONFIG=config.hyperlumic
make KCONFIG_CONFIG=config.hyperlumic flash FLASH_DEVICE=/dev/serial/by-path/platform-xhci-hcd.4.auto-usb-0:1.4:1.0
