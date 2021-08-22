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
# The purpose of this script is to provide some basic linstrap functions

## TODO Add additional environment variables about the running process. (i.e. /proc/$$/status)

function checkdir_or_make() {
  if checkdir $*; then
    echo "good!"
  else
    mkdir -pv "$DIR" || exit 1
  fi
  return 0
}

function checkdir_or_prompt() {
  if checkdir $*; then
    echo "found!"
  else
    declare -l ANS
    read -r -N 1 -p "missing, create it? y/[n] " ANS
    if [ "$ANS" == "y" ]; then
      echo " created!"
      mkdir -vp "$DIR" || exit 1
      return 0
    fi
    echo "bailing out."
    exit 128
  fi
}

function checkdir_or_fail() {
  if checkdir $*; then
    echo "success!"
  else
    echo "missing, bailing out!"
    error "Opps, something is horribly wrong!" "See the above error for details."
    exit $?
  fi
}

function checkdir() {
  VAR1="${3:-${APP_ROOT}}"
  eval "DIR=\"\${APP_$1:-$2}\"" # Get variable or default
  [[ ${DIR} =~ "^/" ]] || DIR="${VAR1}/${DIR}" # Is path absolute?
  echo -n "  Checking directory \"$(realpath --relative-to="${LINSTRAP_ROOT}" "${DIR}")\"... " # Output status
  eval "declare -g APP_$1=\"\$DIR\"" # Save new variable
  if [ -d "${DIR}" ]; then
    return 0 # Exists
  else
    return 128 # Not exist
  fi
}

function makedir() {
  [ -z "$3" ] && return 128
  eval "DIR_ROOT=\"\${APP_$1}\""
  [ -z "${DIR_ROOT}" ] && return 128
  DIR_NEW="${DIR_ROOT}/$3"
  eval "declare -g APP_$2=\"\$DIR_NEW\"" # Save new variable
  [ -d "${DIR_NEW}" ] && return 0
  mkdir -vp "${DIR_NEW}" 2> /dev/null
}

function run_module() {
  MODULE=$1
  TASK=$2
  shift 2
  set -- "$@"

  FILENAME_PRE="${APP_MODULES}/${MODULE}.pre.sh"
  if [ -f "$FILENAME_PRE" ]; then
    source "$FILENAME_PRE" || error "There was a critical error encountered in the \"$FILENAME_PRE\" script."
  fi

  FILENAME_MODULE="${LINSTRAP_MODULES}/${MODULE}.${TASK}.sh"
  if [ -f "$FILENAME_MODULE" ]; then
    source "$FILENAME_MODULE" || error "There was a critical error encountered in the \"$FILENAME_MODULE\" script."
  else
    error "The specified script \"$FILENAME_MODULE\" appears to be missing."
  fi
}

function run_script() {
  FILENAME=$1
  shift
  set -- "$@"

  FILENAME_INIT="${APP_ROOT}/${FILENAME}.init.sh"
  if [ -f "$FILENAME_INIT" ]; then
    source "$FILENAME_INIT" || error "There was a critical error encountered in the \"$FILENAME_INIT\" script."
  fi

  FILENAME_SCRIPT="${APP_ROOT}/${FILENAME}.script.sh"
  if [ -f "$FILENAME_SCRIPT" ]; then
    source "$FILENAME_SCRIPT" || error "There was a critical error encountered in the \"$FILENAME_SCRIPT\" script."
  else
    error "The specified script \"${FILENAME_SCRIPT}\" appears to be missing."
  fi
}

function runScript() {
  FILENAME=$1
  shift
  set -- "$@"

  FILENAME_INIT="${APP_SRC}/${FILENAME}.init.sh"
  if [ -f "${FILENAME_INIT}" ]; then
    . "${FILENAME_INIT}" # || error "There was a critical error encountered in the \"${FILENAME_INIT}\" script."
  fi

  FILENAME_ENV="${APP_SRC}/${FILENAME}.env.sh"
  if [ -f "${FILENAME_ENV}" ]; then
    . "${FILENAME_ENV}" # || error "There was a critical error encountered in the \"${FILENAME_ENV}\" script."
  fi

  FILENAME_SCRIPT="${APP_SRC}/${FILENAME}.script.sh"
  if [ -f "${FILENAME_SCRIPT}" ]; then
    . "${FILENAME_SCRIPT}" # || error "There was a critical error encountered in the \"${FILENAME_SCRIPT}\" script."
  else
    error "The specified script \"${FILENAME_SCRIPT}\" appears to be missing."
  fi
}

function check_var() {
  eval "[ ! \${$1} ] && error \"No! The variable '$1' is unset. Is it declared in the '${LINSTRAP_SCRIPTS}/env' script?\""
}

function var_dump() {
  echo -n "{$1=\"$(eval "echo -n \${$1}")\"}"
}

function check_file() {
  if [ ! -f "$1" ]; then
    error "\nyes... :( The$2 file \"$1\" does not exist!"
  fi
}

function last_arg() {
  for i; do :; done
  builtin echo -ne "${i}"
}

function crash() {
  ob_end "CRASH" || true
  # TODO Wait and terminate the ob_start before exiting.
  if [ "$#" == 0 ]; then
    echo "Oops, something went wrong..."
  else
    echo "&4$*"
  fi
  exit 1
}

function debug () {
	if [ "${VERBOSE}" == "${_NO}" ] && [ "$#" -gt 0 ]; then
		printf "%s\n" "$*" >&2
	fi
}
