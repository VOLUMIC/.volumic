#!/bin/bash

cd ~/klipper

make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc
make menuconfig KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.acc

make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.hyperlumic
make menuconfig KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.hyperlumic

make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic
make menuconfig KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.ultralumic

make clean KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta
make menuconfig KCONFIG_CONFIG=/home/Volumic/VyperOS/updater/config.manta
