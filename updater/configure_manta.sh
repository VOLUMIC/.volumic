#!/bin/bash

cd ~/klipper
make clean KCONFIG_CONFIG=~/printer_data/config/.volumic/updater/config.manta
make menuconfig KCONFIG_CONFIG=~/printer_data/config/.volumic/updater/config.manta
