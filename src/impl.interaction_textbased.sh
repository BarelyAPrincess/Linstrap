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

function error() {
  MSGBOX_COLOR=${CODE_ERROR}
  MSGBOX_TITLE="!!! ERROR ERROR ERROR ERROR !!!"
  MSGBOX_TEXT=( "$@" )
  msgboxShow
  exit 1
}

function warningbox() {
  MSGBOX_COLOR=${CODE_WARNING}
  MSGBOX_TITLE="!!! NOTICE NOTICE NOTICE NOTICE !!!"
  MSGBOX_TEXT=( "$@" )
  msgboxShow
}

function infobox() {
  MSGBOX_COLOR=${CODE_GOOD}
  MSGBOX_TITLE=$1
  shift
  MSGBOX_TEXT=( "$@" )
  msgboxShow
}

function msgbox() {
  MSGBOX_COLOR=${CODE_GOOD}
  MSGBOX_TEXT=( "$@" )
  msgboxShow
}

function msg() {
  echo -e "${CODE_DEF} $1 ${CODE_RESET}"
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

function msgboxInternal() {
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

function msgboxShow() {
  builtin echo
  MSGBOX_WIDTH=${MSGBOX_WIDTH:-${WIDTH}}
  MSGBOX_BORDER=$(repeat "═" "${MSGBOX_WIDTH}")
  builtin echo -e "${MSGBOX_COLOR} ╔═${MSGBOX_BORDER}═╗ ${CODE_RESET}"
  if [ ! -z "${MSGBOX_TITLE}" ]; then
    builtin echo -e "${MSGBOX_COLOR} ║ ${CODE_BLINK}$(alignCenter "${MSGBOX_WIDTH}" "::: ${MSGBOX_TITLE} :::";)${CODE_RESET}${MSGBOX_COLOR} ║ ${CODE_RESET}"
    builtin echo -e "${MSGBOX_COLOR} ║ $(alignCenter "${MSGBOX_WIDTH}" " ";) ║ ${CODE_RESET}"
  fi
  for TEXT in "${MSGBOX_TEXT[@]}"; do
    builtin echo -e "${MSGBOX_COLOR} ║ $(msgboxInternal "${MSGBOX_WIDTH}" "${TEXT}";)${CODE_RESET}${MSGBOX_COLOR} ║ ${CODE_RESET}"
  done
  builtin echo -e "${MSGBOX_COLOR} ╚═${MSGBOX_BORDER}═╝ ${CODE_RESET}"
  builtin echo
  unset MSGBOX_COLOR MSGBOX_TITLE MSGBOX_TEXT MSGBOX_WIDTH MSGBOX_ALIGNMENT
}
