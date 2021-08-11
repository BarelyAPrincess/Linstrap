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

CPU_COUNT=24

PATH=$PATH:/$SYSTEM_LINSTRAP/$LINSTRAP_BINARIES
echo $PATH

ls -la "/$SYSTEM_LINSTRAP/$LINSTRAP_BINARIES"

/$SYSTEM_LINSTRAP/$LINSTRAP_BINARIES/make -j $CPU_COUNT

cd $SYSTEM_LINSTRAP/$LINSTRAP_KERNEL

INSTALL_PATH=$SYSTEM_BOOT make install -j $CPU_COUNT

INSTALL_MOD_PATH=$SYSTEM_MODULES make modules_install -j $CPU_COUNT

# bash -c "cd $LINSTRAP_BUILD_INITRD && find * | grep -Ev \"^(proc|dev|sys)\" | tee | cpio --create -H newc" | gzip -9 > "output/initrd.img-linstrap$VERSION"
