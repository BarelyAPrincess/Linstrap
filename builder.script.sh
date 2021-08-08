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

declare -a TASKS
TASKS+=(${1})

function poptask() {
    if [[ " ${TASKS[@]} " =~ " ${1} " ]]; then
        return ${true}
    else
        return ${false}
    fi
}

LINSTRAP_CONFIG_VALUES=$LINSTRAP_BUILD/values.conf
LINSTRAP_CONFIG_DEFAULTS=$LINSTRAP_BUILD/defaults.conf

if poptask clean; then
	PROMPT_DEFAULT="n"
	if prompt_yes_no "This function will delete all configuration and build files from the workspace. Do you wish to continue?"; then
		echo "Cleaning workspace..."
		
		rm $LINSTRAP_CONFIG_VALUES
		rm $LINSTRAP_CONFIG_DEFAULTS
	fi
	exit 0
fi

if [ ! -f "$LINSTRAP_CONFIG_VALUES" ]; then
	PROMPT_DEFAULT="n"
	if ! prompt_yes_no "There is no configuration file, shall we create it?"; then
		error "Can't continue without the configuration file. Bailing out."
	fi

	# Empty config file
	echo "" > $LINSTRAP_CONFIG_VALUES

	TASKS=+("interviewer")
fi

if poptask interviewer; then
	# TODO Do a version check of base config. Maybe utilize a dummy git repository?
	if [ -f "$LINSTRAP_CONFIG_DEFAULTS" ]; then
		PROMPT_DEFAULT="n"
		prompt_options_basic "A previous base configuration exists, it could be outdated. Would you like to update it?"
	else
		PROMPT_RESULT="y"
	fi
	if [ "$PROMPT_RESULT" == "y" ]; then
		run_module builder initconfig
		declare -p | grep -E "$INITCONF_PREFIX" | sed -E 's/^declare -- //g' > "$LINSTRAP_CONFIG_DEFAULTS"
	else
		source "$LINSTRAP_CONFIG_DEFAULTS" || error "Failed to retrive the base configuration files."
	fi

	prompt_options_basic "Would you like to run the config interviewer now or accept the defaults?" i Interviewer d Defaults c Cancel
	if [ "$PROMPT_RESULT" == "c" ]; then
		exit 0
	elif [ "$PROMPT_RESULT" == "i" ]; then
		# Loads interviewer questions from the module
		run_module builder interviewer

		# TODO Read the interviewer questions one-by-one and prompt the user

		echo -n "  Is host arch X86_64? "
		[ ${ARCH} == "$(uname -m)" ] || error "nope! Only X86_64 is supported at this moment."
		echo "yes!"

		echo -n "  Running as root? "
		[ `whoami` == "root" ] || error "nope! This script can only be ran as root at this moment due to its use of 'chroot'. Support for 'fakechroot' will be added later.$LINSTRAP_ERROR_APPEND"
		echo "yes!"

	elif [ "$PROMPT_RESULT" == "d" ]; then

	fi
fi

source "$LINSTRAP_CONFIG_VALUES" || error "Failed to retrive the build configuration files."

if poptask setup; then
	msg "Setting up build environment..."


fi

if poptask build; then
	msg "Starting the build process..."


fi
