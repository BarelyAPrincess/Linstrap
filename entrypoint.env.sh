LINSTRAP_NAME="linstrap"
LINSTRAP_TITLE="Welcome to the Linux OS Bootstraping and Launcher Utility"
LINSTRAP_AUTHOR="Created by Amelia S. Greene (BarelyAPrincess)"
LINSTRAP_VERSION="2021.07-$(git rev-parse --short --verify HEAD 2>/dev/null)"
LINSTRAP_ERROR_APPEND="\n  Please consider providing feedback and/or contributing to this project at https://github.com/PenoaksDev/Linstrap"

[ $WIDTH ] || WIDTH=100
[ $HEIGHT ] || HEIGHT=$(($WIDTH / 3))

sterilize_bool USE_COLOR

case "$TERM" in
	xterm-color|*-256color ) USE_COLOR=$(yes);;
esac

# Check if setting the color causes an error
if [ $USE_COLOR == "0" ] && ! tput setaf 1 >&/dev/null; then
	USE_COLOR=$(no)
fi

if is USE_COLOR; then
	[ $CODE_DEF ] || CODE_DEF="\e[96m"
	[ $CODE_BLINK ] || CODE_BLINK="\e[5m"
	[ $CODE_GOOD ] || CODE_GOOD="\e[1;36;36m"
    [ $CODE_ERROR ] || CODE_ERROR="\e[1;41;97m"
    [ $CODE_WARNING ] || CODE_WARNING="\e[1;36;36m"
	[ $CODE_RESET ] || CODE_RESET="\e[39;0m"
fi

LC_ALL=${LC_ALL:-en_US.utf-8}
EPOCH=$(date +%s)

echo -n "  Detecting host boot method: "
if [ -f /sys/firmware/efi ]; then
    BOOTED_WITH_EFI=$(yes)
    echo "EFI"
else
    BOOTED_WITH_EFI=$(no)
    echo "BIOS"
fi