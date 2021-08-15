#!/bin/bash
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

# exec 2>debug.txt
# set -x

# TODO Implement an error trap
# Create a temporary pipe file
declare -g OB_PIPE
OB_PIPE="pipe" # $(mktemp -u -t pipe.XXXXXX)"
declare -g OB_STATE=0 # Tracks state of output buffer. 0=not started, 1=started
declare -g OB_LENGTH=0

function ob_start () {
    [ ${OB_STATE} != 0 ] && echo "ERROR: Can not nest output buffers!" && exit 1

    if [ -e "${OB_PIPE}" ] && [ "$(file "${OB_PIPE}")" != "pipe: fifo*" ]; then
        rm -f "${OB_PIPE}"
    fi
    if [ -e "${OB_PIPE}" ]; then
        echo "Output buffer pipe already exists!" >&2
        # TODO Check if pipe is in use
    else
        mknod "${OB_PIPE}" p || ( echo "Failed to make output buffer pipe!" && exit 1 )
    fi

    OB_STATE=1
    OB_LENGTH=$((${#1}+4))
    
    echo "${CODE_GOOD}${1}... ${CODE_RESET}[ ${CODE_WARNING}WAIT${CODE_RESET} ]"

    {
        LINES=0
        while read -r LINE; do
            LINES=$((${LINES}+1))
            printf "%4d: %s [ %s ] %s%s\n" "${LINES}" "${CODE_GOOD}" "$(cut -d ' ' -f 1 < /proc/uptime)" "${CODE_RESET}" "${LINE}"

            # echo "  ${LINES}: ${CODE_GOOD} [  ] ${CODE_RESET}${LINE}"
        done < "${OB_PIPE}"
        ob_end_loop $(($LINES+1))
    } &
    
    exec 1> "${OB_PIPE}"
}

function ob_end_loop () {
    [ ${OB_STATE} != 1 ] && echo "ERROR: 'ob_start' function was never called!" && exit 1

    rm -f "${OB_PIPE}"

    tput sc
    tput cub 999
    tput cuf "${OB_LENGTH}"
    tput cuu "$1"
}

function ob_end () {
    [ ${OB_STATE} != 1 ] && echo "ERROR: 'ob_start' function was never called!" && exit 1

    exec 1>&0
    wait

    echo "${CODE_RESET}[ ${CODE_GOOD}${1:-DONE}${CODE_RESET} ]"
    tput rc

    echo

    OB_STATE=0
}

function prepend () {
    sed -E "s/^/${1:-Output} /g"
}
