#!/bin/bash

cd ~/klipper
make clean KCONFIG_CONFIG=/home/Volumic/printer_data/config/.volumic/updater/config.ultralumic
make KCONFIG_CONFIG=/home/Volumic/printer_data/config/.volumic/updater/config.ultralumic
