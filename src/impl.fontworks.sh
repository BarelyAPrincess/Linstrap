#!/bin/null
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
# Linstrap font and color functions

## Setup Colored Console ##

bool USE_COLOR "$(yes)" || true

case "${TERM}" in
	xterm-color|*-256color ) USE_COLOR=$(yes);;
esac

# Check if setting the color causes an error
if is USE_COLOR; then
  if tput setaf 1 >&/dev/null; then
    # Color is enabled, so allow echo to parse colors
    alias echo="echo -e"
  else
    USE_COLOR=$(no)
  fi
fi

declare -g CODE_DEF="${CODE_DEF:-\e[96m}"
declare -g CODE_BLINK="${CODE_BLINK:-\e[5m}"
declare -g CODE_GOOD="${CODE_GOOD:-\e[1;36;36m}"
declare -g CODE_ERROR="${CODE_ERROR:-\e[1;41;97m}"
declare -g CODE_WARNING="${CODE_WARNING:-\e[1;36;36m}"
declare -g CODE_RESET="${CODE_RESET:-\e[39;0m}"

if is USE_COLOR; then
  echo "${CODE_GOOD}COLORED console is enabled!"
else
  echo "COLORED console is disabled!"
  unset CODE_DEF CODE_BLINK CODE_GOOD CODE_ERROR CODE_WARNING CODE_RESET
fi

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

function repeat() {
  for i in $(seq $2); do
    builtin echo -n "$1"
  done
}

# echo; echo -en "[!............................................................]\r[."; tput sc; for i in $(seq 60); do tput rc; tput cub1; echo -n ".|"; tput sc; sleep 1; done; echo; echo
