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

LINSTRAP_NAME="linstrap"
LINSTRAP_TITLE="Welcome to the Linux OS Bootstraping and Launcher Utility"
LINSTRAP_AUTHOR="Created by Amelia S. Greene (BarelyAPrincess)"
LINSTRAP_VERSION="2021.08-$(git rev-parse --short --verify HEAD 2>/dev/null)"

declare -ig CPU_COUNT=0
for cores in $(cat /proc/cpuinfo | grep "cpu cores" | sed -E "s/^.*([0-9]+.*$)/\1/g"); do
    CPU_COUNT=$((CPU_COUNT+cores))
done
[ "${CPU_COUNT}" -lt "1" ] && CPU_COUNT=4
echo "Found ${CPU_COUNT} cpu cores."

WIDTH=${WIDTH:-100}
HEIGHT=${HEIGHT:-$(($WIDTH / 3))}

DIALOG_TITLE="Linstrap: Linux OS Bootstrapping and Launcher Utility"
DIALOG_WIDTH=${DIALOG_WIDTH:-$(($WIDTH / 2))}
DIALOG_HEIGHT=${DIALOG_HEIGHT:-$(($HEIGHT / 2))}

DIALOG_OK=0
DIALOG_CANCEL=1
DIALOG_HELP=2
DIALOG_EXTRA=3
DIALOG_ITEM_HELP=4
DIALOG_ESC=255

EPOCH=$(date +%s)

if [ -f /sys/firmware/efi ]; then
    BOOTED_WITH_EFI=$(yes)
else
    BOOTED_WITH_EFI=$(no)
fi
