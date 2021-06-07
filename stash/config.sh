#!/bin/bash
LC_ALL=C

if [[ "${1}" =~ "help" ]]; then
	echo "Command Arguments: $0 [CONFIG_FILE] [OUTPUT_FILE] [APPEND_FILES...]"
	exit 0
fi

function join_by() {
	local d="$1"
	shift
	local f="$1"
	shift
	printf %s "$f" "${@/#/$d}"
}

function warning() {
        echo -e "\r   WARNING: ${1}"
}

function error() {
        echo -e "   ERROR: ${1}"
        exit 1
}

function cc() {
        if [ $? != 0 ]; then
		echo
                echo "ERROR: See console output!"
                exit $?
        fi
}

yes() {
    [ $1 ] && eval "$1=0" || echo -n 0
}

no() {
    [ $1 ] && eval "$1=1" || echo -n 1
}

sterilize_bool() {
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

sterilize_bool VERBOSE

function is() {
	[ $1 ] && eval "CV=\${$1}" || CV=$1
	[ "$CV" == "0" ] || return 1
}

function is_verbose() {
	[ $VERBOSE == "0" ] || return 1
}

# TODO Implement arguments

[[ "${1}" =~ ^$ ]] && FILE_CONFIG="${PWD}/.config" || FILE_CONFIG="`realpath ${1}`"
[[ "${2}" =~ ^$ ]] && FILE_OUTPUT="${FILE_CONFIG}-updated" || FILE_OUTPUT="`realpath ${2}`"
[[ "${3}" =~ ^$ ]] && FILE_APPEND="${FILE_CONFIG}-android" || FILE_APPEND="`realpath ${3}`"

is_verbose && echo -e "--> Verbosity is Enabled <--\n"

[ ! -f "${FILE_CONFIG}" ] && error "The input file of \"${FILE_CONFIG}\" does not exist!"
[ ! -f "${FILE_CONFIG}" ] && error "The append file of \"${FILE_OUTPUT}\ does not exist!"
[ -f "${FILE_OUTPUT}" ] && error "The output file of \"${FILE_OUTPUT}\" already exists!"

echo "Patching Key Value Configuration File"
echo
echo "Input File: \"$FILE_CONFIG\""
echo "Append File: \"$FILE_APPEND\""
echo "Output File: \"$FILE_OUTPUT\""
echo

declare -A CONFIGURATION
declare -i MAXLEN=20

function human_value {
	case "$1" in
	"" )
		echo "Empty String"
		;;
	"y" | "yes" )
		echo "Yes"
		;;
	"n" | "no" )
		echo "No"
		;;
	"m" | "mod" )
		echo "Module"
		;;
	"d" | "def" | "is not set" )
		echo "Default"
		;;
	*)
		echo "$1"
		;;
	esac
}

declare -i STATS_LOADED=0
declare -i STATS_IGNORED=0
declare -i STATS_CHANGED=0
declare -i STATS_MATCHED=0
declare -i STATS_LINES=0

exec 3< "${FILE_CONFIG}"
while read -ru 3 KEYVALUE; do
	let STATS_LINES++

	# XXX WORK AROUND
	[[ "${KEYVALUE}" =~ ^\#\ [xA-Z0-9_]+\ is\ not\ set ]] && KEYVALUE="`echo -n "${KEYVALUE:2}" | sed -E "s/ is not set//g"`=d"

	if [[ "${KEYVALUE}" =~ ^[xA-Z0-9_]+= ]]; then
		let STATS_LOADED++

		KEY=$(echo "${KEYVALUE}" | cut -sd '=' -f 1)
        	VALUE=$(echo "${KEYVALUE}" | cut -sd '=' -f 2)

		[[ "${VALUE}" =~ ^\$ ]] && VALUE="d"

		[ "${#KEY}" -gt "$MAXLEN" ] && MAXLEN=${#KEY}

		CONFIGURATION[$KEY]="${VALUE}" || warning "Action Failed!"

		echo -ne "Reading Configuration to Array... [LOADED $STATS_LOADED] $KEY                                                   \r"
	elif [[ ! "${KEYVALUE}" =~ ^\$ ]]; then
		is_verbose && echo -e "\rLine # is empty... skipping.                                                "
	else
		warning "The configuration line \"$KEYVALUE\" in the input file did not pass the regex test."
	fi
done

echo -e "Reading Configuration to Array... Complete                                                 "

exec 3>&-

declare -a COLUMN_WIDTHS=(50 30 30 10)
declare -a COLUMN_TITLES=("KEY" "CURRENT VALUE" "THIS VALUE" "ACTION TAKEN")
declare -i TABLE_WIDTH=0
declare -i STATS_LINES=0

# let TABLE_WIDTH=$MAXLEN_KEY+$MAXLEN_VALUE_CUR+$MAXLEN_VALUE_NEW+$MAXLEN_ACTION

function repeat() {
	perl -E "say '$1' x $2"
}

function table_header() {
	is_verbose || return 0

	HEAD="   |"
	for IDX in "${!COLUMN_WIDTHS[@]}"; do
		TITLE="${COLUMN_TITLES[$IDX]}"
		WIDTH="${COLUMN_WIDTHS[$IDX]}"
		SPACING=`repeat " " $(($WIDTH-${#TITLE}))`

        	HEAD+=" ${TITLE}${SPACING} |"
	done

	let TABLE_WIDTH=${#HEAD}-5

	table_divide
	echo "${HEAD}"
	table_divide
}

function table_divide() {
	is_verbose || return 0

	echo "   +`repeat "-" ${TABLE_WIDTH}`+"
}

function table_body() {
	is_verbose || return 0

	declare -a BODY=("$@")

	echo -n "   |"
	for IDX in "${!BODY[@]}"; do
		TEXT="${BODY[$IDX]}"
		WIDTH="${COLUMN_WIDTHS[$IDX]}"
		SPACING=`repeat " " $(($WIDTH-${#TEXT}))`

		echo -n " ${TEXT}${SPACING} |"
	done
	echo ""
}

table_header

exec 3< "${FILE_APPEND}"
while read -ru 3 KEYVALUE; do
        # XXX WORK AROUND
        [[ "${KEYVALUE}" =~ ^\#\ [xA-Z0-9_]+\ is\ not\ set ]] && KEYVALUE="`echo -n "${KEYVALUE:2}" | sed -E "s/ is not set//g"`=d"

	if [[ "${KEYVALUE}" =~ ^[xA-Z0-9_]+= ]]; then
		KEY=$(echo "${KEYVALUE}" | cut -sd '=' -f 1)
		VALUE_CUR="${CONFIGURATION[$KEY]}"
		VALUE_NEW="$(echo ${KEYVALUE} | cut -sd '=' -f 2)"

		[[ "${VALUE_NEW}" =~ ^\$ ]] && VALUE_NEW="d"

		HUMAN_VALUE_CUR="$(human_value ${VALUE_CUR})"
		HUMAN_VALUE_NEW="$(human_value ${VALUE_NEW})"

		if [[ "${HUMAN_VALUE_CUR}" == "${HUMAN_VALUE_NEW}" ]]; then
			ACTION="MATCHES"
			let STATS_MATCHED++
		elif [[ "${HUMAN_VALUE_CUR}" == "Yes" || "${HUMAN_VALUE_NEW}" == "Module" ]]; then
			ACTION="CHANGED"
			CONFIGURATION[$KEY]="${VALUE_NEW}" || warning "Action failed!"
			let STATS_CHANGED++
		else
			ACTION="IGNORED"
			let STATS_IGNORED++
		fi

		echo -en "Comparing Configuration...[$STATS_IGNORED IGNORED] [$STATS_MATCHED MATCHES] [$STATS_CHANGED CHANGES] $KEY                                    \r"

		table_body "${KEY}" "${HUMAN_VALUE_CUR}" "${HUMAN_VALUE_NEW}" "${ACTION}"
	elif [[ "${KEYVALUE}" =~ ^\$ ]]; then
		is_verbose && echo -e "\rLine # is empty... skipping.                                                "
	else
		warning "The configuration line \"$KEYVALUE\" in append file did not pass the regex test."
	fi
done

exec 3>&-

echo -e "\rComparing Configuration... Complete                                                              "

table_divide

exec 3> "${FILE_OUTPUT}"

echo -e "# DO NOT EDIT\n# This configuration was auto generated\n" >&3

for KEY in "${!CONFIGURATION[@]}"; do
	VALUE="${CONFIGURATION[$KEY]}"
	if [[ "$VALUE" == "d" ]]; then
		echo "# ${KEY} is not set" >&3
	else
		echo "${KEY}=${VALUE}" >&3
	fi
done

exec 3>&-

echo
