# This software may be modified and distributed under the terms
# of the MIT license.  See the LICENSE file for details.
#
# Copyright (c) 2021 Amelia Sara Greene <barelyaprincess@gmail.com>
# Copyright (c) 2021 Penoaks Publishing LLC <development@penoaks.com>
  
#!/bin/bash

[ $LINSTRAP_DIR ] || LINSTRAP_DIR="${0%/*}"

. ${LINSTRAP_DIR}/func
. ${LINSTRAP_DIR}/colors

FG_DEFAULT=$_CYAN

echo
echo "&D   ██▓     ██▓ ███▄    █   ██████ ▄▄▄█████▓ ██▀███   ▄▄▄       ██▓███  "
echo "&D  ▓██▒    ▓██▒ ██ ▀█   █ ▒██    ▒ ▓  ██▒ ▓▒▓██ ▒ ██▒▒████▄    ▓██░  ██▒"
echo "&D  ▒██░    ▒██▒▓██  ▀█ ██▒░ ▓██▄   ▒ ▓██░ ▒░▓██ ░▄█ ▒▒██  ▀█▄  ▓██░ ██▓▒"
echo "&D  ▒██░    ░██░▓██▒  ▐▌██▒  ▒   ██▒░ ▓██▓ ░ ▒██▀▀█▄  ░██▄▄▄▄██ ▒██▄█▓▒ ▒"
echo "&D  ░██████▒░██░▒██░   ▓██░▒██████▒▒  ▒██▒ ░ ░██▓ ▒██▒ ▓█   ▓██▒▒██▒ ░  ░"
echo "&D  ░ ▒░▓  ░░▓  ░ ▒░   ▒ ▒ ▒ ▒▓▒ ▒ ░  ▒ ░░   ░ ▒▓ ░▒▓░ ▒▒   ▓▒█░▒▓▒░ ░  ░"
echo "&D  ░ ░ ▒  ░ ▒ ░░ ░░   ░ ▒░░ ░▒  ░ ░    ░      ░▒ ░ ▒░  ▒   ▒▒ ░░▒ ░     "
echo "&D    ░ ░    ▒ ░   ░   ░ ░ ░  ░  ░    ░        ░░   ░   ░   ▒   ░░       "
echo "&D      ░  ░ ░           ░       ░              ░           ░  ░         "
echo
echo "&F ╔═══════════════════════════════════════════════════════════════════╗ "
echo "&F ║ Welcome to the Linux System Bootstraper Utility v1.0              ║ "
echo "&F ║ Created by Amelia S. Greene (BarelyAPrincess)                     ║ "
echo "&F ║                                                                   ║ "
echo "&F ║ This software may be modified and distributed under the terms of  ║ "
echo "&F ║ the MIT License. See LICENSE file for details.                    ║ "
echo "&F ╚═══════════════════════════════════════════════════════════════════╝ "
echo

echo "Checking Environment..."

echo -n "  X86_64? "
ARCH=`uname -m`
[ ${ARCH} == "x86_64" ] || error "&4No. Only X86_64 is at present supported."
echo "yes"

printf "  Running as root? "
[ `whoami` == "root" ] || error "&4No. This script must be executed with root privileges."
echo "yes"

echo
echo "LinStrap Directory: ${LINSTRAP_DIR}"
echo
