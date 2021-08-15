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
# Build the Linstrap Kernel and install files in their rightful place.

PROJECT_NAME="default"
PROJECT_DIR="${APP_DATA}/${PROJECT_NAME}"



make -j $CPU_COUNT

INSTALL_PATH=$SYSTEM_BOOT make -C "" install -j $CPU_COUNT

INSTALL_MOD_PATH=$SYSTEM_MODULES make -C "" modules_install -j $CPU_COUNT

# bash -c "cd $LINSTRAP_BUILD_INITRD && find * | grep -Ev \"^(proc|dev|sys)\" | tee | cpio --create -H newc" | gzip -9 > "output/initrd.img-linstrap$VERSION"


    # TODO Check and extract the kernel to the correct directory
    # TODO Make universal compatibility, maybe use a custom chroot to build kernel.

    #apt install build-essential libncurses-dev libelf-dev

    #apt -y install git gcc curl make libxml2-utils flex m4
    #apt -y install openjdk-8-jdk lib32stdc++6 libelf-dev
    #apt -y install libssl-dev python-enum34 python-mako syslinux-utils