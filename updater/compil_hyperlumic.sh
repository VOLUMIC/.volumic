#!/bin/bash

cd ~/klipper
make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.hyperlumic
make KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.hyperlumic
