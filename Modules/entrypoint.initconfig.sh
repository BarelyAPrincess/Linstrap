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
# Prepares confiruation to be used by the interviewer

declare -ug INITCONF_PREFIX="LINSTRAP_BUILDCONF"
declare -ug INITCONF_KEY

function initconf_keyname() {
    INITCONF_KEY="$1"
    eval "unset ${INITCONF_PREFIX}_${INITCONF_KEY}; declare -Ag ${INITCONF_PREFIX}_${INITCONF_KEY}"
}

function set_metaconf() {
    KEY=$1
    shift
    eval "${INITCONF_PREFIX}_${INITCONF_KEY}[${KEY}]=\"$@\""
}

function set_initconf_default() {
    set_metaconf DEFAULT $1
}

function set_initconf_title() {
    set_metaconf TITLE $1
}

function set_initconf_question() {
    set_metaconf QUESTION $1
}

function set_initconf_options() {
    set_metaconf OPTIONS "$@"
}

initconf_keyname DIRTY_SETUP
	set_initconf_default 1

initconf_keyname ARCH
	set_initconf_default "x86_64"
	set_initconf_title "cpu arch"
	set_initconf_question "What CPU arch would you like to use?"
	set_initconf_options x86_64 x86

initconf_keyname BOOT_METHOD
	set_initconf_default "EFI"
	set_initconf_title "boot method"
	set_initconf_question "Which boot method would you like?"
	set_initconf_options BIOS EFI

initconf_keyname INITRD_BRANCH
    set_initconf_default "bleeding"
    set_initconf_title "initrd branch"
    set_initconf_question "What initrd branch would you like to setup?"
    set_initconf_options bleeding stable custom
