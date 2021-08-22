#!/dev/null
# shellcheck shell=bash
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
# Create a reliable debian rescue system for in the event that any Linstrap OS fails to start

RESCUE_DIR="${APP_PROJECTS}/LinstrapRescue"
mkdir -vp "${RESCUE_DIR}" 2>/dev/null

RESCUE_SUITE="jessie"
RESCUE_MIRROR="https://deb.debian.org/debian"
RESCUE_HOSTNAME="linstrap-rescue"

function chroot_exec() {
    chroot "${RESCUE_DIR}" "$@"
}

ob_start "Creating a Linstrap Rescue OS"

### Create Base System With Debootstrap ###
/usr/sbin/debootstrap --variant minbase "${RESCUE_SUITE}" "${RESCUE_DIR}" "${RESCUE_MIRROR}"

### Add Extra Repos ###
mkdir -pv "${RESCUE_DIR}/etc/apt/sources.list.d" 2>/dev/null || true

echo "deb ${RESCUE_MIRROR} ${RESCUE_SUITE} non-free contrib" > "${RESCUE_DIR}/etc/apt/sources.list.d/extra_repos.list"
echo "deb http://security.debian.org/ ${RESCUE_SUITE}/updates main non-free contrib" > "${RESCUE_DIR}/etc/apt/sources.list.d/security_repos.list"

### Create MOTD ###
cat <<EOF > "${RESCUE_DIR}/etc/motd"
==================================================
Welcome to Linstrap Rescue OS ${LINSTRAP_VERSION}

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
==================================================
EOF

### Prepare for General Use ###

mkdir -pv "${RESCUE_DIR}/linstrap" 2>/dev/null
cat <<EOF > "${RESCUE_DIR}/linstrap/build.info"
# build.info
#
# Linstrap
#
#    version: $(git rev-parse --short --verify HEAD)
# build host: $(hostname -f)
# build arch: $(dpkg --print-architecture)
# build date: $(date -R)

# the following config variables were set during build:
EOF

for var in ${!APP_*}; do
    echo "${var}=${!var}" >> "${RESCUE_DIR}/linstrap/build.info"
done
for var in ${!LINSTRAP_*}; do
    echo "${var}=${!var}" >> "${RESCUE_DIR}/linstrap/build.info"
done

echo "proc /proc proc defaults 0 0" > "${RESCUE_DIR}/etc/fstab"

echo "${RESCUE_HOSTNAME}" > "${RESCUE_DIR}/etc/hostname"

# write /etc/hosts
cat <<EOF > "${RESCUE_DIR}/etc/hosts"
127.0.0.1	localhost
127.0.1.1   ${RESCUE_HOSTNAME}

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
EOF

echo "fs.inotify.max_user_watches=524288" >> "${RESCUE_DIR}/etc/sysctl.conf"

chroot_exec <<EOF
#debconf-set-selections <<EOF
# Interface to use:
# Choices: Dialog, Readline, Gnome, Kde, Editor, Noninteractive
#debconf debconf/frontend select Noninteractive
#EOF

find /usr/share/locale -maxdepth 1 -mindepth 1 -type d ! -iname 'en*' -execdir rm -rf '{}' \+

passwd --delete root

apt --yes --force-yes update
apt --yes --force-yes upgrade

apt-get --assume-yes install man-db manpages info nano

# work around http://bugs.debian.org/686965
if $(which insserv > /dev/null); then
    cd /etc/init.d
    insserv $(ls | grep -vFx -e rc -e rcS -e skeleton -e README)
fi
EOF

rm -rf "${RESCUE_DIR}/lib/modules"

### Setup Networking ###
rm -f "${RESCUE_DIR}"/etc/udev/rules.d/*_persistent-net.rules

### Write DHCP Config ###
cat <<EOF > "${RESCUE_DIR}/etc/systemd/network/dhcp.network"
[Match]
Name=e*

[Network]
DHCP=yes
EOF

ln -sf /run/systemd/resolve/resolv.conf "${RESCUE_DIR}/etc/resolv.conf"
chroot_exec systemctl enable systemd-resolved.service

# add network note to /etc/motd
cat <<EOF >> "${RESCUE_DIR}/etc/motd"
If you have a network interface and you want to use DHCP,
you can bring it up with:

 systemctl start systemd-networkd

For more information about system network configuration,
see ip(8) and systemd.network(5)
==================================================
EOF

### Create root bashrc ###

cat <<EOF > "${RESCUE_DIR}"/root/.bashrc
# ~/.bashrc: executed by bash(1) for non-login shells.

export PS1='\$? \h:\w\\$ '
umask 022

# You may uncomment the following lines if you want 'ls' to be colorized:
export LS_OPTIONS='--color=auto'
eval "\$(dircolors)"
alias ls='ls \$LS_OPTIONS'
alias ll='ls \$LS_OPTIONS -l'
alias l='ls \$LS_OPTIONS -lA'
#
# Some more alias to avoid making mistakes:
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
EOF

### Final Step - Cleanup Root ###

chroot_exec <<EOF
apt-get --assume-yes --purge autoremove
apt-get clean
rm -f "/var/cache/apt/"*.bin
rm -rf "/var/lib/apt/lists/"*
mkdir "/var/lib/apt/lists/partial"
EOF

ln -sf /proc/mounts "${RESCUE_DIR}/etc/mtab"

/sbin/ldconfig -r "${RESCUE_DIR}"

# Undo FakeChroot
# rm -rf "${RESCUE_DIR}/proc"
# mkdir "${RESCUE_DIR}/proc"
# if [ "$ROOT_BUILD" != 'true' ]; then
#     debirf_exec dpkg-divert --remove /sbin/ldconfig
#     if [ -e "$RESCUE_DIR/sbin/ldconfig.REAL" ] ; then
# 	mv -f "$RESCUE_DIR/sbin/ldconfig.REAL" "$RESCUE_DIR/sbin/ldconfig"
#     fi
#     debirf_exec dpkg-divert --remove /usr/bin/ldd
#     if [ -e "$RESCUE_DIR/usr/bin/ldd.REAL" ] ; then
# 	mv -f "$RESCUE_DIR/usr/bin/ldd.REAL" "$RESCUE_DIR/usr/bin/ldd"
#     fi
# fi

### Finally, finally package the system ###

find "${RESCUE_DIR}" | sed -E "s#${RESCUE_DIR}/{0,1}##g" | grep -Ev "^(tmp|proc|dev|sys)/" | tee -a "${OB_PIPE}" | eval "cd \"${RESCUE_DIR}\" && cpio --create -H \"newc\" | gzip -9 >\"${LINSTRAP_DATA}/rootfs.img-rescue${LINSTRAP_VERSION}\""

ob_end "SUCCESS"
