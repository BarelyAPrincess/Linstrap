#!/bin/bash
migration_check setup_workspace 1.0

# clone Linstrap kernel
git clone git@github.com:PenoaksDev/Linstrap-Kernel.git $LINSTRAP_DATA/Kernel

make honeypot_defconfig