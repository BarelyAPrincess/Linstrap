#
##############################################################################
##  This software may be modified and distributed under the terms
##  of the MIT license.  See the LICENSE file for details.
##
##  Unless required by applicable law or agreed to in writing,
##  software distributed under the License is distributed on an
##  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
##  KIND, either express or implied.  See the License for the
##  specific language governing permissions and limitations
##  under the License.
##
##  Copyright (c) 2021 Amelia Sara Greene <barelyaprincess@gmail.com>
##  Copyright (c) 2021 Penoaks Publishing LLC <development@penoaks.com>
##
##  Linstrap: Linux OS Bootstrapping and Launcher for UN*X
##############################################################################
#
# Do Not Directly Run

LINSTRAP_MODULES_INITRD=$LINSTRAP_MODULES/scripts_initrd

# for s in `ls ${LINSTRAP_MODULES_INITRD}/custom_*`; do
#	test -e "$s" && source $s
# done

# Run on Ubuntu 16.04 and up!

makedir ROOT DATA Data
makedir DATA PROJECT linstrap

BOOTDISK_FILE="$LINSTRAP_PROJECT/bootdisk_linstrap.img"
BOOTDISK_SIZE=2000

mkdir -vp "${LINSTRAP_DATA}/mountpoints/boot" 2>/dev/null
mkdir -vp "${LINSTRAP_DATA}/mountpoints/root" 2>/dev/null

trap rollback ERROR

dd if=/dev/zero of="$BOOTDISK_FILE" bs=1M count=$BOOTDISK_SIZE

sfdisk bootdisk.img <<EOF
label: gpt
unit: sectors
2048,2048,21686148-6449-6E6F-744E-656564454649,*
,1048576,C12A7328-F81F-11D2-BA4B-00A0C93EC93B,*
,1048576,0FC63DAF-8483-4772-8E79-3D69D8477DE4
,,0FC63DAF-8483-4772-8E79-3D69D8477DE4
EOF

BOOTDISK_LOOPDEVICE="/dev/loop99"
losetup -P $BOOTDISK_LOOPDEVICE "$BOOTDISK_FILE"

# losetup -fP "$BOOTDISK_FILE"
# BOOTDISK_LOOPDEVICE=$(losetup | grep "$BOOTDISK_FILE" | cut -d ' ' -f 1)
# [ -z "$BOOTDISK_LOOPDEVICE" ] && error "Failed to find loop device!"

mkfs.ext4 "${BOOTDISK_LOOPDEVICE}p3"
mkfs.ext4 "${BOOTDISK_LOOPDEVICE}p4"

mount -o noatime "${BOOTDISK_LOOPDEVICE}p3" "${LINSTRAP_DATA}/mountpoints/boot"
mount -o noatime "${BOOTDISK_LOOPDEVICE}p4" "${LINSTRAP_DATA}/mountpoints/root"



umount "${LINSTRAP_DATA}/mountpoints/boot"
umount "${LINSTRAP_DATA}/mountpoints/root"
losetup -d "$BOOTDISK_LOOPDEVICE"

exit 0

[ "$(ls -A $LINSTRAP_BUILD)" ] && error "We can't The build directory is dirty. We must have an empty directory to continue!"


# base-files,busybox-static,bash,dialog,fdisk,e2fsprogs,bsdutils,grep,sed,tar

# The minimum required files for base OS
REQUIRE="base-files,libc6"

# Install BusyBox
REQUIRE="$REQUIRE,busybox-static"

# The minimum required files for mount
# REQUIRE="$REQUIRE,mount,libmount1,libblkid1,libsmartcols1"

# libcrypt1,debian-security-support,sendfile,dpkg
EXCLUDE=""

echo "Creating Base Files"
mkdir bin 2>/dev/null
echo -e "#!/bin/busybox sh\necho \"initrd\"\nexit 0" > bin/dpkg-deb && chmod a+x bin/dpkg-deb

ln -sv /bin/busybox bin/true
ln -sv /bin/busybox bin/sh
ln -sv /bin/busybox bin/mount

echo
echo "Executing Debootstrap"
./debootstrap/debootstrap "$@" --no-resolve-deps --extractor=ar --variant empty --include="$REQUIRE" --exclude="$EXCLUDE" --components="main,restricted,universe,multiverse" focal .

echo

#chroot . <<EOF
#echo "Updating container!"
#  /bin/busybox --install
#  rm -r /etc/{apt,dpkg}
#  rm -r /usr/share/{man,doc,locale}
#  rm -r /var/cache/apt
#  rm -r /var/lib/{apt,dpkg}
#  rm -r /debootstrap
#EOF

echo "Dumping Debootstrap Log"
tail ./debootstrap/debootstrap.log