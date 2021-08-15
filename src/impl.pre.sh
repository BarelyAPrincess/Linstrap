#!/dev/null
# shellcheck shell=bash disable=SC2120
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

declare -x _NO="NO"
declare -x _YES="YES"

yes() {
  printf '%s' "${_YES}"
}

no() {
  printf '%s' "${_NO}"
}

value() {
  if [ -z "${1}" ]; then
    return 1
  else
    eval "printf \"\${${1}}\"" 2>/dev/null
    return $?
  fi
}

# Expects a variable name passed and updates the value
# Add "|| true" to prevent script from returning
bool() {
  KEY="${1:-}"
  DEF="${2:-$(no)}" # Default is false
  VAL="${DEF}"
  [ -z "${KEY}" ] && return "${DEF}"
  # Is the key a variable?
  if declare -p "${KEY}" &>/dev/null; then
    if VAL="$(value "${KEY}")"; then
      VAL="$(is "${VAL}" "${DEF}")"
      [ -z "${VAL}" ] && VAL=$?
      declare -g "${KEY}=\"${VAL}\""
    fi
  elif ( type "${KEY}" 2>&1 | grep -E "function|builtin" &>/dev/null ); then
    if VAL="$(${KEY})"; then
      [ -z "${VAL}" ] && VAL=$?
    fi
  fi
  is "${VAL}" "${DEF}" &>/dev/null
}

# Specificlly accepts a value to evaluate
is() {
  KEY="${1:-}"
  DEF="${2:-$(no)}" # Default is false
  VAL="${DEF}"
  [ -z "${KEY}" ] && return "${DEF}"
  case "${KEY}" in
    "${_YES}"|"1"|"yes"|"true")
      yes
      return $?
      ;;
    "${_NO}"|"0"|"no"|"false" )
      no
      return $?
      ;;
    *)
      # Does the key reference a function or builtin?
      if ( type "${KEY}" 2>&1 | grep -E "function|builtin" &>/dev/null ); then
        if VAL=$(${KEY}); then
          [ -z "${VAL}" ] && return $?
          is "${VAL}" "${DEF}"
          return $?
        fi
      # Is the key reference another variable?
      elif declare -p "${KEY}" &>/dev/null; then
        is "$(echo -n "\${${KEY}}")" "${DEF}" &>/dev/null
        return $?
      fi
      ;;
  esac
  [ "${VAL}" = "0" ]
}

is_false() {
  ! is "*@"
}

bool VERBOSE "$(no)" || true

mute() {
  eval "$@" &>/dev/null
  return $?
}

filter() {
  REGEX="${1}"
  while read -r INPUT; do
    [[ "${INPUT}" =~ ${REGEX} ]] && echo "${INPUT}"
  done
  return 0
}

function is_verbose() {
	is VERBOSE || return 1
}

# XXX This function needs to work in "sh" too so scripts can determine is the "declare" function is available.
function has_declare() {
  [ "$(type declare)" != "declare: not found" ]
  return $?
}

function is_builtin() {
  [ "$(LC_ALL=C type -t "${1}")" == "builtin" ]
}

function is_function() {
  [ "$(LC_ALL=C type -t "${1}")" == "function" ]
}

function join_by() {
  local d="$1"; shift; local f="$1"; shift; printf %s "${f}" "${@/#/${d}}"
}