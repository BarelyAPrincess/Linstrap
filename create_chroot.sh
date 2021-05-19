#!/bin/bash
# Creates a private chroot enrironment for running java (e.g., gradle build system) without installing java on the host system.
# TODO Make a script that does the same setup as this script but works on Windows and Mac.
# TODO Create error logger so scripting errors can be reported to the developer.
# TODO Make it so non-privilaged users can run it.
# TODO Continue to make the chroot smaller and smaller.

# Step 0:
# - Check for AMD64 - we won't support any other arch unless someone contributes.
# - Check for OS - At present only Linux is supported

PWD=`dirname $0`

source "${PWD}/bin/functions"
check_env

[ -d "${CHROOT}" ] && echo "Detected the existence of chroot, the script might fail until chroot is first deleted."

# Step 1: Download and extract debootstrap binary

if [ -d "${PWD}/bin/debootstrap" ]; then
    echo "Debootstrap should already be downloaded. If script fails, try deleting \"bin/debootstrap\"."
else
    wget -O- http://deb.debian.org/debian/pool/main/d/debootstrap/debootstrap_1.0.123.tar.gz | tar -xvz -C "${PWD}/bin"
fi

# wget -O- https://salsa.debian.org/installer-team/debootstrap/-/archive/master/debootstrap-master.tar.gz | tar -xvzf - -C bin/debootstrap

# Step 2: Run debootstrap

[ -d "${CHROOT}" ] || mkdir -p "${CHROOT}"

DEBOOTSTRAP_DIR="${PWD}/bin/debootstrap" ${PWD}/bin/debootstrap/debootstrap --arch amd64 --variant minbase --include "openjdk-8-jre" xenial "${CHROOT}" http://us.archive.ubuntu.com/ubuntu

# echo "8:23:respawn:/usr/sbin/chroot ${CHROOT} /sbin/getty 38400 tty8 >> /etc/inittab"
# init q