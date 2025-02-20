# STOP klipper
sudo service klipper stop

# STOP KlipperScreen
sudo service KlipperScreen stop

# Update klipper
cd /home/Volumic/klipper
git pull

# Update configurations
cd /home/Volumic/printer_data/config/.volumic
git pull

# Update KlipperScreen
cd /home/Volumic/KlipperScreen
git pull

# Update mainsail
cd /home/Volumic/mainsail
rm -R ./*
rm .version
wget -q -O mainsail.zip https://github.com/mainsail-crew/mainsail/releases/latest/download/mainsail.zip && unzip mainsail.zip && rm mainsail.zip

# Update Moonraker
cd /home/Volumic/moonraker
git pull

# Update accelerometer MCU
cd /home/Volumic/klipper
make clean KCONFIG_CONFIG=/home/Volumic/printer_data/config/.volumic/updater/config.acc
make KCONFIG_CONFIG=/home/Volumic/printer_data/config/.volumic/updater/config.acc
make KCONFIG_CONFIG=/home/Volumic/printer_data/config/.volumic/updater/config.acc flash FLASH_DEVICE=/dev/serial/by-path/platform-xhci-hcd.4.auto-usb-0:1:1.0

# Update MCU
cd /home/Volumic/klipper
make clean KCONFIG_CONFIG=/home/Volumic/printer_data/config/.volumic/updater/config.hyperlumic
make KCONFIG_CONFIG=/home/Volumic/printer_data/config/.volumic/updater/config.hyperlumic
cd /home/Volumic/klipper/lib/hidflash
./hid-flash ~/klipper/out/klipper.bin serial/by-path/platform-fd840000.usb-usb-0:1:1.0

# Make updater scripts executable
cd /home/Volumic/printer_data/config/.volumic/updater/
sudo chmod +x *.sh

# Update Mainsail images
sudo cp /home/Volumic/printer_data/config/.volumic/system/img/icons/*.* /home/Volumic/mainsail/img/icons/
sudo cp /home/Volumic/printer_data/config/.volumic/system/img/themes/*.* /home/Volumic/mainsail/img/themes/
sudo cp /home/Volumic/printer_data/config/.volumic/system/img/*.* /home/Volumic/mainsail/img/

# Update system
sudo apt update

# Update system logo
cd /home/Volumic/printer_data/config/.volumic/system/
sudo cp watermark.png /usr/share/plymouth/themes/armbian/
sudo plymouth-set-default-theme -R armbian

sudo shutdown -h 0
