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

NEWLINE=$'\n'

# Msgbox Code

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

function msgboxShow() {
    dialog \
        --backtitle "${DIALOG_TITLE}" \
        --title "${MSGBOX_TITLE:-}" \
        --trim \
        --clear \
        --cr-wrap \
        --msgbox "$(join_by "\n" "${MSGBOX_TEXT[@]}")" \
        "${DIALOG_HEIGHT}" \
        "${MSGBOX_WIDTH:-${DIALOG_WIDTH}}"
    DIALOG_CODE=$?

    unset MSGBOX_COLOR MSGBOX_TITLE MSGBOX_TEXT MSGBOX_WIDTH MSGBOX_ALIGNMENT
}

# Menu Code

function menuClear() {
    unset MENU_OPTIONS
    declare -a MENU_OPTIONS
}

function menuAddOption() {
    MENU_OPTIONS[$((${#MENU_OPTIONS[@]}+1))]="${1}${NEWLINE}${2}"
}

function menuShow() {
    declare -a MENU_COMPILED
    
    for KEY in "${!MENU_OPTIONS[@]}"; do
        MENU_COMPILED+=("${KEY}")
        VALUE="$(echo "${MENU_OPTIONS[${KEY}]}" | cut -d "${NEWLINE}" -f 1)"
        MENU_COMPILED+=("${VALUE}")
    done

    exec 3>&1
    DIALOG_RESULT=$(dialog \
        --backtitle "${DIALOG_TITLE}" \
        --title "Main Menu" \
        --clear \
        --cancel-label "Quit" \
        --menu "What would you like to do?" \
        "${DIALOG_HEIGHT}" \
        "${DIALOG_WIDTH}" \
        10 \
        "${MENU_COMPILED[@]}" 2>&1 1>&3)
    DIALOG_CODE=$?
    exec 3>&-

    msgbox "Menu Result: {DIALOG_CODE=\"${DIALOG_CODE}\",DIALOG_RESULT=\"${DIALOG_RESULT}\"}"
    
    case ${DIALOG_CODE} in
        "${DIALOG_CANCEL}")
        #clear
        msgboxShow "No errors, hooray! Goodbye!"
        return 0
        ;;
        ${DIALOG_ESC})
        #clear
        echo "Aborted..." >&2
        exit 1
        ;;
    esac
    case ${DIALOG_RESULT} in
        0 )
            #clear
            msgboxShow "No errors, hooray! Goodbye!"
            return 0
            ;;
        * )
            COMMAND="$(echo "${MENU_OPTIONS[${DIALOG_RESULT}]}" | cut -d "${NEWLINE}" -f 2)"
            unset MENU_OPTIONS MENU_COMPILED
            eval "${COMMAND}" || return 1
            return 0
            ;;
    esac

    error "Reached End of Menu Script" "This Should Never Happen!"
}

menuClear
