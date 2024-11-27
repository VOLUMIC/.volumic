#!/bin/bash

cd ~/klipper
make clean KCONFIG_CONFIG=~/printer_data/config/.volumic/updater/config.hyperlumic
make KCONFIG_CONFIG=~/printer_data/config/.volumic/updater/config.hyperlumic
