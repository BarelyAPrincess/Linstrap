#!/bin/bash
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
    read -N 1 -p "missing, create it? y/[n] " ANS
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
  VAR1="${3:-$LINSTRAP_ROOT}"
  eval "DIR=\"\${LINSTRAP_$1:-$2}\"" # Get variable or default
  [[ $DIR =~ "^/" ]] || DIR="$VAR1/$DIR" # Is path absolute?
  echo -n "  Checking directory \"$(realpath --relative-to="$LINSTRAP_ROOT" "$DIR")\"... " # Output status
  eval "LINSTRAP_$1=\"\$DIR\"" # Save new variable
  if [ -d "$DIR" ]; then
    return 0 # Exists
  else
    return 128 # Not exist
  fi
}

function run_module() {
  MODULE=$1
  TASK=$2
  shift 2
  set -- $*

  FILENAME_PRE="${LINSTRAP_MODULES}/${MODULE}.pre.sh"
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
  set -- $*

  FILENAME_INIT="${LINSTRAP_ROOT}/${FILENAME}.init.sh"
  if [ -f "$FILENAME_INIT" ]; then
    source "$FILENAME_INIT" || error "There was a critical error encountered in the \"$FILENAME_INIT\" script."
  fi

  FILENAME_SCRIPT="${LINSTRAP_ROOT}/${FILENAME}.script.sh"
  if [ -f "$FILENAME_SCRIPT" ]; then
    source "$FILENAME_SCRIPT" || error "There was a critical error encountered in the \"$FILENAME_SCRIPT\" script."
  else
    error "The specified script \"$FILENAME_SCRIPT\" appears to be missing."
  fi
}

function yes() {
  [ $1 ] && eval "$1=0" || echo -n 0
}

function no() {
  [ $1 ] && eval "$1=1" || echo -n 1
}

function is() {
  [ $1 ] && eval "CV=\${$1}" || CV=$1
  [ "$CV" == "0" ] || return 0
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

function sterilize_bool() {
  eval "CV=\${$1}"
  case $CV in
    "1"|"yes"|"true")
      EV=$(yes)
      ;;
    "0"|"no"|"false"|"")
      EV=$(no)
      ;;
    *)
      # Is there a way to prevent this from executing malicious code?
      eval "$CV &>/dev/null"
      EV="$?"
      ;;
  esac

  [ $1 ] && eval "$1=\"$EV\"" || return $EV
}

function echo() {
if [ $# -eq 0 ]; then
  builtin echo
else
  OPTIONS="-e"
  VAR=""
  eval set -- "$(getopt -n "echo" -o neE --long version --long help -- "$@")"
  while :; do
    if [ "$1" == "--help" ]; then
      builtin echo --help
      exit $?
    elif [ "$1" == "--version" ]; then
      builtin echo --version
      exit $?
    elif [ "$1" == "--" ]; then
      shift
      VAR="$*"
      break;
    else
      OPTIONS="$OPTIONS $1"
    fi
    shift
  done

  if [ "$(LC_ALL=C type -t parse_color)" == "function" ]; then
    VAR="$(parse_color "$VAR")"
  else
    VAR="${VAR//[&@][0-9A-Za-z]/}"
  fi

  builtin echo $OPTIONS "$VAR"
fi
}

function last_arg() {
  for i; do :; done
  builtin echo -ne $i
}

function is_builtin() {
  [ "$(LC_ALL=C type -t ${1})" == "builtin" ]
}

function join_by() {
  local d="$1"; shift; local f="$1"; shift; printf %s "$f" "${@/#/$d}"; }

function crash() {
  echo "&4$@"
  exit 1
}

function alignCenter() {
  LM=$((${2}/2-${#1}/2))
  RM=$LM
  [ $((${#1}%2)) == "1" ] && RM=$((RM-1))
  echo -en "`printf '%*s' $LM`$1`printf '%*s' $RM`"
}

function repeat() {
  for i in $(seq $2); do
    builtin echo -n "$1"
  done
}

function error() {
  echo
  msg "$CODE_ERROR ╔═$(repeat "═" $WIDTH)═╗ $CODE_RESET" >&2
  msg "$CODE_ERROR ║ $CODE_BLINK$(alignCenter "!!! ERROR ERROR ERROR ERROR !!!" "$WIDTH";)$CODE_RESET$CODE_ERROR ║ $CODE_RESET" >&2
  msg "$CODE_ERROR ║ $(repeat " " $WIDTH) ║ $CODE_RESET" >&2
  for STR in "$@"; do
    msg "$CODE_ERROR ║ $(alignCenter "$STR" "$WIDTH";) ║ $CODE_RESET" >&2
  done
  msg "$CODE_ERROR ╚═$(repeat "═" $WIDTH)═╝ $CODE_RESET" >&2
  echo
  exit 1
}

function warningbox() {
  echo
  msg "$CODE_WARNING ╔═$(repeat "═" $WIDTH)═╗ $CODE_RESET" >&2
  msg "$CODE_WARNING ║ $CODE_BLINK$(alignCenter "!!! NOTICE NOTICE NOTICE NOTICE !!!" "$WIDTH";)$CODE_RESET$CODE_WARNING ║ $CODE_RESET" >&2
  msg "$CODE_WARNING ║ $(repeat " " $WIDTH) ║ $CODE_RESET" >&2
  for STR in "$@"; do
    msg "$CODE_WARNING ║ $(alignCenter "$STR" "$WIDTH";) ║ $CODE_RESET" >&2
  done
  msg "$CODE_WARNING ╚═$(repeat "═" $WIDTH)═╝ $CODE_RESET" >&2
  echo
  exit 1
}

function infobox() {
  echo
  msg "$CODE_GOOD ╔═$(repeat "═" $WIDTH)═╗ $CODE_RESET"
  msg "$CODE_GOOD ║ $CODE_BLINK$(alignCenter "$1" "$WIDTH";)$CODE_RESET$CODE_GOOD ║ $CODE_RESET"
  shift
  for STR in "$@"; do
    msg "$CODE_GOOD ║ $CODE_GOOD$(alignCenter "$STR" "$WIDTH";)$CODE_RESET ║ $CODE_RESET"
  done
  msg "$CODE_GOOD ╚═$(repeat "═" $WIDTH)═╝ $CODE_RESET"
  echo
}

function msgbox() {
  echo
  msg "$CODE_GOOD ╔═$(repeat "═" $WIDTH)═╗ $CODE_RESET"
  for STR in "$@"; do
    msg "$CODE_GOOD ║ $CODE_GOOD$(alignCenter "$STR" "$WIDTH";)$CODE_RESET ║ $CODE_RESET"
  done
  msg "$CODE_GOOD ╚═$(repeat "═" $WIDTH)═╝ $CODE_RESET"
  echo
}

function msg() {
  echo -e "$CODE_DEF $1 $CODE_RESET"
}
