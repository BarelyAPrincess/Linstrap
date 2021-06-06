# This software may be modified and distributed under the terms
# of the MIT license.  See the LICENSE file for details.
#
# Copyright (c) 2021 Amelia Sara Greene <barelyaprincess@gmail.com>
# Copyright (c) 2021 Penoaks Publishing LLC <development@penoaks.com>
#
#!/bin/bash
# Creates a private chroot enrironment for running java (e.g., gradle build system) without installing java on the host system.
# TODO Make a script that does the same setup as this script but works on Windows and Mac.
# TODO Create error logger so scripting errors can be reported to the developer.
# TODO Make it so non-privilaged users can run it.
# TODO Continue to make the chroot smaller and smaller.

# Step 0:
# - Check for AMD64 - we won't support any other arch unless someone contributes.
# - Check for OS - At present only Linux is supported

[ $LINSTRAP_DIR ] || LINSTRAP_DIR="${0%/*}"

. ${LINSTRAP_DIR}/startup.sh

[ -d "${LINSTRAP_CHROOT}" ] && echo "Detected the existence of chroot, the scripts could fail unless the directory is deleted."

# Step 1: Download and extract debootstrap binary

if [ -d "${LINSTRAP_DIR}/bin/debootstrap" ]; then
    echo "Debootstrap should already be downloaded. If script fails, try deleting \"bin/debootstrap\"."
else
    wget -O- http://deb.debian.org/debian/pool/main/d/debootstrap/debootstrap_1.0.123.tar.gz | tar -xvz -C "${LINSTRAP_DIR}/bin"
fi

# wget -O- https://salsa.debian.org/installer-team/debootstrap/-/archive/master/debootstrap-master.tar.gz | tar -xvzf - -C bin/debootstrap

# Step 2: Run debootstrap

[ -d "${LINSTRAP_CHROOT}" ] || mkdir -p "${CHROOT}"

DEBOOTSTRAP_DIR="${LINSTRAP_DIR}/bin/debootstrap" ${LINSTRAP_DIR}/bin/debootstrap/debootstrap --arch amd64 --variant minbase --include "openjdk-8-jre" xenial "${LINSTRAP_CHROOT}" http://us.archive.ubuntu.com/ubuntu

# echo "8:23:respawn:/usr/sbin/chroot ${CHROOT} /sbin/getty 38400 tty8 >> /etc/inittab"
# init q
