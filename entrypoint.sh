#!/bin/bash -e
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
# This is the entrypoint for the entire Linstrap setup utility.
# No other script should be ran beside this one first.

if [ "$0" == "*bash" -o "$0" == "*sh" ]; then
    echo "Script must be ran from it's own bash process."
    return 1
fi

## TODO Check the script is being executed with bash, sh will likely have compatibility issues.

## TODO Create a function that creates additional environment variables about the running process. (i.e. /proc/$$/status)

function error() {
	echo "SEVERE ERROR! ${@}${LINSTRAP_ERROR_APPEND}"
	exit 1
}

## Locate what directory we must use
if [ $LINSTRAP_ROOT ]; then
	LINSTRAP_ROOT=$(realpath "$LINSTRAP_ROOT")
	if [ -d $LINSTRAP_ROOT ]; then
		error "The LINSTRAP_ROOT variable points to an invalid target. Specified directory is \"$LINSTRAP_ROOT\"."
    fi
else
    # Resolve links: $0 may be a link
    PRG="$0"
    # Need this for relative symlinks.
    while [ -h "$PRG" ] ; do
        ls=`ls -ld "$PRG"`
        link=`expr "$ls" : '.*-> \(.*\)$'`
        if expr "$link" : '/.*' > /dev/null; then
            PRG="$link"
        else
            PRG=`dirname "$PRG"`"/$link"
        fi
    done
    SAVED="`pwd`"
    cd "`dirname \"$PRG\"`/" >/dev/null
    LINSTRAP_ROOT="`pwd -P`"
    cd "$SAVED" >/dev/null
fi

source $LINSTRAP_ROOT/entrypoint.init.sh || error "Could not include the entrypoint.init.sh file."

# From here forward is the actual script code.

declare -l FUNCTION
declare -a QUEUE
declare -a DONE
FUNCTION=${1:-nofunc}
QUEUE+=($FUNCTION)
shift
echo

# TODO implement a menu function for displaying a list of functions available.

function popqueue() {
    if [[ " ${QUEUE[@]} " =~ " ${1} " ]]; then
        DONE+=($1)
        return ${true}
    else
        return ${false}
    fi
}

if popqueue clean; then
	run_script builder clean $*
fi

if popqueue setup; then
	run_script builder setup $*
fi

if popqueue setup; then
	run_script builder interviewer $*
fi

if popqueue build; then
	run_script builder build $*
fi

if popqueue help; then # Show linstrap help
	run_script help $*
fi

if popqueue nofunc; then # No function specified
    warningbox "You must specify a function to continue." "${0} [function] [options]" "Try the 'help' function for more information."
fi

if popqueue usage; then # Show linstrap usage
    msgbox "${0} [function] [options]" "Use the 'help' function for more information."
fi

echo
if [[ " ${QUEUE[@]} " == " ${DONE[@]} " ]]; then
    msg "No errors, hooray!"
else
    error "Oops, something went wrong..." "Maybe the function you specified was not recognized." "Try '${0} help' for more information."
fi

exit 0

if [ ! -f "$LINSTRAP_BUILD/linstrap.conf" ]; then
	if [ "$(ls -A "$LINSTRAP_HOME")" ]; then
		error "We detected that the build directory \"$LINSTRAP_HOME\" is not empty and is missing configuration."
	fi

	echo
	echo "We detected that the build directory \"$LINSTRAP_HOME\" is missing the linstrap confiruration file."
	echo

	PROMPT_DEFAULT="n"
	if ! prompt_yes_no "Shall we create the default configuration file?"; then
		error "Can't continue without the configuration file. Bailing out."
	fi

	include_or_fail BUILD_DEFAULT modules/build_env 

	declare -p | grep -E "$CONFIG_PREFIX" | sed -E 's/^declare -- //g' > "$LINSTRAP_HOME/linstrap.conf"
	QUEUE+=("interviewer")
fi