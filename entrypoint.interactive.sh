declare -l PROMPT_RESULT # Declare for later

function prompt_text() {
  read -p "What initrd package would you like to setup? [e.g., \"bleeding\", \"stable\", \"custom\"] " PACK
  declare -l PACK

  case $PACK in
    "bleeding" | "stable")
      if [ -d "$LINSTRAP_BUILD/initrd" ]; then
        echo "The initrd directory already exists."
        echo " [r]ename directory"
        echo " [u]pdate from git repository"
        echo " [d]elete directory"
        echo " [a]bort"
        read -N 1 -p "What would you like to do? " ANS
        if [ "$ANS" == "r" ]; then
          mv "$LINSTRAP_BUILD/initrd" "$LINSTRAP_BUILD/initrd.bk$EPOCH"
        elif [ "$ANS" == "u" ]; then
          echo
          echo
          git -C "$LINSTRAP_BUILD/initrd" pull
          exit 0
        elif [ "$ANS" == "d" ]; then
          rm -r "$LINSTRAP_BUILD/initrd"
        else
          exit 0
        fi
      else
        git clone git@github.com:PenoaksDev/Linstrap-Stencils.git -b "initrd-$PACK" "$LINSTRAP_BUILD/initrd"
        echo Success!
      fi
      ;;
    "custom")
      error "Not implemented. Custom is an option that will be implemented later."
      ;;
    *)
      error "Please select a valid option."
      ;;
  esac
}

function prompt_yes_no() {
  prompt_options_basic "$1" y Yes n No
  if [ "$PROMPT_RESULT" == "y" ]; then
    return 0
  else
    return 1
  fi
}

# ( message, options... ) - last option is default
function prompt_options_basic() {
  MSG="$1"
  shift
  [ "${#@}" -lt "4" ] && error "SCRIPT ERROR: At least two options must be provided. [${@}]"
  [ $((${#@} % 2)) == "1" ] && error "SCRIPT ERROR: The options provided must be in key/value order."
  declare -A OPTS
  for i in $(seq 1 2 ${#@}); do
    K=$1
    shift
    V="$(echo "$1" | sed -E "s/($K)/[\1]/i")"
    shift
    OPTS+=([$K]=$V)
  done
  MSG="$MSG ( ${OPTS[@]} ) "
  [ -z "$PROMPT_DEFAULT" ] || MSG="$MSG[$PROMPT_DEFAULT] "

  while true; do
    read -p "$MSG" -N 1 -s -i "$PROMPT_RESULT" PROMPT_RESULT
    if [[ " ${!OPTS[@]} " =~ " $PROMPT_RESULT " ]]; then
        echo $PROMPT_RESULT
        return 0
    fi
    if [ ! -z "$PROMPT_DEFAULT" ]; then
        PROMPT_RESULT=$PROMPT_DEFAULT
        echo $PROMPT_RESULT
        unset PROMPT_DEFAULT
        return 0
    fi
    echo "Invalid choice made, try again!"
  done
  echo
}
