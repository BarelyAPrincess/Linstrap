#!/bin/bash -e
[ $LINSTRAP_HOME ] || exit 1

: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}
: ${HEIGHT=0}
: ${WIDTH=0}

unset MENU_OPTIONS_TITLE MENU_OPTIONS_COMMAND
declare -a MENU_OPTIONS_TITLE MENU_OPTIONS_COMMAND

addMenuOption() {
    MENU_OPTIONS_TITLE+=("$1") # Option Title
    MENU_OPTIONS_COMMAND+=("$2") # Option Command
}

for s in `ls ${LINSTRAP_HOME}/scripts/menus/0*`; do
	test -e "$s" && source $s
done

for K in "${!MENU_OPTIONS_TITLE[@]}"; do
    MENU_OPTIONS_COMPILED+=" $(($K+1)) '${MENU_OPTIONS_TITLE[$K]}'"
done

while :; do
    exec 3>&1
    selection=$(eval "dialog --backtitle 'Linstrap v1.0' --title 'Menu' --clear --cancel-label 'Nevermind' --menu 'Select Action' $HEIGHT $WIDTH 10 ${MENU_OPTIONS_COMPILED} 2>&1 1>&3")
    exit_status=$?
    exec 3>&-
    case $exit_status in
        $DIALOG_CANCEL)
        clear
        echo "Terminated..."
        exit
        ;;
        $DIALOG_ESC)
        clear
        echo "Aborted..."
        exit 1
        ;;
    esac
    case $selection in
        0 )
            clear
            "Terminated..."
            exit
            ;;
        * )
            eval "${MENU_OPTIONS_COMMAND[$(($selection-1))]}"
            read
            ;;
    esac
done
