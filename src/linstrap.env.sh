LINSTRAP_NAME="linstrap"
LINSTRAP_TITLE="Welcome to the Linux OS Bootstraping and Launcher Utility"
LINSTRAP_AUTHOR="Created by Amelia S. Greene (BarelyAPrincess)"
LINSTRAP_VERSION="2021.07-$(git rev-parse --short --verify HEAD 2>/dev/null)"
LINSTRAP_ERROR_APPEND="\n  Please consider providing feedback and/or contributing to this project at https://github.com/PenoaksDev/Linstrap"
LINSTRAP_DIALOG_WIDTH=40
LINSTRAP_DIALOG_HEIGHT=20

WIDTH=${WIDTH:-100}
HEIGHT=${HEIGHT:-$(($WIDTH / 3))}

DIALOG_WIDTH=${DIALOG_WIDTH:-$(($WIDTH / 2))}
DIALOG_HEIGHT=${DIALOG_HEIGHT:-$(($HEIGHT / 2))}

EPOCH=$(date +%s)

if [ -f /sys/firmware/efi ]; then
    BOOTED_WITH_EFI=$(yes)
else
    BOOTED_WITH_EFI=$(no)
fi
