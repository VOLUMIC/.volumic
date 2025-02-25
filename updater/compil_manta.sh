#!/bin/bash

cd ~/klipper
make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta
make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta
