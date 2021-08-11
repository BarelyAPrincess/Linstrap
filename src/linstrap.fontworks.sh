#!/bin/bash -eE
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
# Linstrap font and color functions

## Setup Colored Console ##

sterilize_bool USE_COLOR

case "${TERM}" in
	xterm-color|*-256color ) USE_COLOR=$(yes);;
esac

# Check if setting the color causes an error
if [ "${USE_COLOR}" == "0" ] && ! tput setaf 1 >&/dev/null; then
	USE_COLOR=$(no)
fi

CODE_DEF="${CODE_DEF:-\e[96m}"
CODE_BLINK="${CODE_BLINK:-\e[5m}"
CODE_GOOD="${CODE_GOOD:-\e[1;36;36m}"
CODE_ERROR="${CODE_ERROR:-\e[1;41;97m}"
CODE_WARNING="${CODE_WARNING:-\e[1;36;36m}"
CODE_RESET="${CODE_RESET:-\e[39;0m}"

is USE_COLOR || unset CODE_DEF CODE_BLINK CODE_GOOD CODE_ERROR CODE_WARNING CODE_RESET

## Screen Manipulation Functions ##

function clear() {
  cursor "2J"
}

function erase() {
  cursor "K"
}

function cursor() {
  builtin echo -ne "\e[$(join_by '' "$@")";
}

function cursor_goto() { # line x column
  cursor "$1" \; "$2" "H"
}

function cursor_save() {
  cursor "s"
}

function cursor_restore() {
  cursor "u"
}

function cursor_down() { # num lines
  cursor "${1:-1}" "B"
}

function cursor_up() { # num lines
  cursor "${1:-1}" "A"
}

function cursor_backward() { # num lines
  cursor "${1:-1}" "D"
}

function cursor_forward() { # num lines
  cursor "${1:-1}" "C"
}

## Color Codes ##

function color() {
  builtin echo -ne "\e[$(join_by \; "$@")m";
}

_BLACK=$(color 30); # &0
_DARK_RED=$(color 31); # &4
_DARK_GREEN=$(color 32); # &2
_DARK_YELLOW=$(color 33); # &6
_DARK_BLUE=$(color 34); # &1
_DARK_MAGENTA=$(color 35); # &5
_DARK_CYAN=$(color 36); # &3
_GRAY=$(color 37); # &7
_DARK_GRAY=$(color 90); # &8
_RED=$(color 91); # &C
_GREEN=$(color 92); # &A
_YELLOW=$(color 93); # &E
_BLUE=$(color 94); # &9
_MAGENTA=$(color 95); # &D
_CYAN=$(color 96); # &B
_WHITE=$(color 97); # &F

_BG_BLACK=$(color 40); # @0
_BG_DARK_RED=$(color 41); # @4
_BG_DARK_GREEN=$(color 42); # @2
_BG_DARK_YELLOW=$(color 43); # @6
_BG_DARK_BLUE=$(color 44); # @1
_BG_DARK_MAGENTA=$(color 45); # @5
_BG_DARK_CYAN=$(color 46); # @3
_BG_GRAY=$(color 47); # @7
_BG_DARK_GRAY=$(color 100); # @8
_BG_RED=$(color 101); # @C
_BG_GREEN=$(color 102); # @A
_BG_YELLOW=$(color 103); # @E
_BG_BLUE=$(color 104); # @9
_BG_MAGENTA=$(color 105); # @D
_BG_CYAN=$(color 106); # @B
_BG_WHITE=$(color 107); # @F

_BOLD=$(color 1); # &L
_NO_BOLD=$(color 21)
_FAINT=$(color 2); # &Z
_OBSECURE=$_FAINT
_NO_FAINT=$(color 22)
_UNDERLINE=$(color 4); # &N
_NO_UNDERLINE=$(color 24)
_MAGIC=$(color 5); # &K
_NO_MAGIC=$(color 25)
_NEGATIVE=$(color 7); # &X
_NO_NEGATIVE=$(color 27)
_HIDDEN=$(color 8); # &M
_NO_HIDDEN=$(color 28)

_RESET_COLOR=$(color 39)
_RESET_ATTR=$(color 0)
_RESET=$(color 39 0); # &R

_DEFAULT=${_DEFAULT:-${_RESET}}

function parse_color() {
  VAR="$*"

  VAR="${VAR//&[0]/${_BLACK}}"
  VAR="${VAR//&[4]/${_DARK_RED}}"
  VAR="${VAR//&[2]/${_DARK_GREEN}}"
  VAR="${VAR//&[6]/${_DARK_YELLOW}}"
  VAR="${VAR//&[1]/${_DARK_BLUE}}"
  VAR="${VAR//&[5]/${_DARK_MAGENTA}}"
  VAR="${VAR//&[3]/${_DARK_CYA}N}"
  VAR="${VAR//&[7]/${_GRAY}}"
  VAR="${VAR//&[8]/${_DARK_GRAY}}"
  VAR="${VAR//&[Cc]/${_RED}}"
  VAR="${VAR//&[Aa]/${_GREEN}}"
  VAR="${VAR//&[Ee]/${_YELLOW}}"
  VAR="${VAR//&[9]/${_BLUE}}"
  VAR="${VAR//&[Dd]/${_MAGENTA}}"
  VAR="${VAR//&[Bb]/${_CYAN}}"
  VAR="${VAR//&[Ff]/${_WHITE}}"

  VAR="${VAR//@[0]/${_DARK_BLACK}}"
  VAR="${VAR//@[4]/${_BG_DARK_RED}}"
  VAR="${VAR//@[2]/${_BG_DARK_GREEN}}"
  VAR="${VAR//@[6]/${_BG_DARK_YELLOW}}"
  VAR="${VAR//@[1]/${_BG_DARK_BLUE}}"
  VAR="${VAR//@[5]/${_BG_DARK_MAGENTA}}"
  VAR="${VAR//@[3]/${_BG_DARK_CYAN}}"
  VAR="${VAR//@[7]/${_BG_GRAY}}"
  VAR="${VAR//@[8]/${_BG_DARK_GRAY}}"
  VAR="${VAR//@[Cc]/${_BG_RED}}"
  VAR="${VAR//@[Aa]/${_BG_GREEN}}"
  VAR="${VAR//@[Ee]/${_BG_YELLOW}}"
  VAR="${VAR//@[9]/${_BG_BLUE}}"
  VAR="${VAR//@[Dd]/${_BG_MAGENTA}}"
  VAR="${VAR//@[Bb]/${_BG_CYAN}}"
  VAR="${VAR//@[Ff]/${_BG_WHITE}}"

  VAR="${VAR//&[Ll]/${_BOLD}}"
  VAR="${VAR//&[Zz]/${_FAINT}}"
  VAR="${VAR//&[Nn]/${_UNDERLINE}}"
  VAR="${VAR//&[Kk]/${_MAGIC}}"
  VAR="${VAR//&[Xx]/${_NEGATIVE}}"
  VAR="${VAR//&[Mm]/${_HIDDEN}}"

  VAR="${VAR//&[Rr]/${_RESET_COLOR}}"
  VAR="${VAR//@[Rr]/${_RESET_ATTR}}"

  VAR="${VAR//[@&]\-/${_RESET}}"

  builtin echo -ne "${_DEFAULT}${VAR}"
}

# Reset the terminal colors first
builtin echo -ne "${_RESET}"

function old_echo() {
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

function repeat() {
  for i in $(seq $2); do
    builtin echo -n "$1"
  done
}

function error() {
  MSGBOX_COLOR=$CODE_ERROR
  MSGBOX_TITLE="!!! ERROR ERROR ERROR ERROR !!!"
  MSGBOX_TEXT=( "$@" )
  generate_msgbox
  exit 1
}

function warningbox() {
  MSGBOX_COLOR=$CODE_WARNING
  MSGBOX_TITLE="!!! NOTICE NOTICE NOTICE NOTICE !!!"
  MSGBOX_TEXT=( "$@" )
  generate_msgbox
}

function infobox() {
  MSGBOX_COLOR=$CODE_GOOD
  MSGBOX_TITLE=$1
  shift
  MSGBOX_TEXT=( "$@" )
  generate_msgbox
}

function msgbox() {
  MSGBOX_COLOR=$CODE_GOOD
  MSGBOX_TEXT=( "$@" )
  generate_msgbox
}

function msg() {
  echo -e "$CODE_DEF $1 $CODE_RESET"
}

function alignLeft() {
  ALIGN_WIDTH="$1"
  shift
  ALIGN_TEXT="$*"
  ALIGN_CLEAN="$(echo -ne "$ALIGN_TEXT")"
  ALIGN_BUFFER=$((${ALIGN_WIDTH}-${#ALIGN_CLEAN}))
  builtin echo -en "${ALIGN_TEXT}$(printf '%*s' ${ALIGN_BUFFER})"
}

function alignCenter() {
  ALIGN_WIDTH="$1"
  shift
  ALIGN_TEXT="$*"
  ALIGN_CLEAN="$(echo "${ALIGN_TEXT}")"
  ALIGN_BUFFER_LM=$(( ${ALIGN_WIDTH}/2-${#ALIGN_CLEAN}/2 ))
  ALIGN_BUFFER_RM=${ALIGN_BUFFER_LM}
  [ $((${#ALIGN_CLEAN}%2)) == "1" ] && ALIGN_BUFFER_RM=$((ALIGN_BUFFER_RM-1))
  builtin echo -en "$(printf '%*s' ${ALIGN_BUFFER_LM})${ALIGN_TEXT}$(printf '%*s' ${ALIGN_BUFFER_RM})"
}

function alignRight() {
  ALIGN_WIDTH="$1"
  shift
  ALIGN_TEXT="$*"
  ALIGN_CLEAN="$(echo $ALIGN_TEXT)"
  ALIGN_BUFFER=$((${ALIGN_WIDTH}-${#ALIGN_CLEAN}))
  builtin echo -en "$(printf '%*s' ${ALIGN_BUFFER})${ALIGN_TEXT}"
}

function content_msgbox() {
  MSGBOX_ALIGNMENT=${MSGBOX_ALIGNMENT:-1}
  case "${MSGBOX_ALIGNMENT}" in
    0)
      alignLeft "$@"
      ;;
    1)
      alignCenter "$@"
      ;;
    2)
      alignRight "$@"
      ;;
  esac
  unset MSGBOX_ALIGNMENT
}

function generate_msgbox() {
  builtin echo
  MSGBOX_WIDTH=${MSGBOX_WIDTH:-${WIDTH}}
  MSGBOX_BORDER=$(repeat "═" "${MSGBOX_WIDTH}")
  builtin echo -e "${MSGBOX_COLOR} ╔═${MSGBOX_BORDER}═╗ ${CODE_RESET}"
  if [ ! -z "${MSGBOX_TITLE}" ]; then
    builtin echo -e "${MSGBOX_COLOR} ║ ${CODE_BLINK}$(alignCenter "${MSGBOX_WIDTH}" "::: ${MSGBOX_TITLE} :::";)${CODE_RESET}${MSGBOX_COLOR} ║ ${CODE_RESET}"
    builtin echo -e "${MSGBOX_COLOR} ║ $(alignCenter "${MSGBOX_WIDTH}" " ";) ║ ${CODE_RESET}"
  fi
  for TEXT in "${MSGBOX_TEXT[@]}"; do
    builtin echo -e "${MSGBOX_COLOR} ║ $(content_msgbox "${MSGBOX_WIDTH}" "${TEXT}";)${CODE_RESET}${MSGBOX_COLOR} ║ ${CODE_RESET}"
  done
  builtin echo -e "${MSGBOX_COLOR} ╚═${MSGBOX_BORDER}═╝ ${CODE_RESET}"
  builtin echo
  unset MSGBOX_COLOR MSGBOX_TITLE MSGBOX_TEXT MSGBOX_WIDTH MSGBOX_ALIGNMENT
}
