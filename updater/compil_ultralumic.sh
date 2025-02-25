#!/bin/bash

cd ~/klipper
make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic
make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic
