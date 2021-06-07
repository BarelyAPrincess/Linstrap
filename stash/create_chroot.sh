
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
