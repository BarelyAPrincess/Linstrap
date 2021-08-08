source $LINSTRAP_ROOT/builder.functions.sh || error "Could not include the app.helper.sh file."
source $LINSTRAP_ROOT/builder.env.sh || error "Could not include the app.env.sh file."

echo "Checking Builder Environment..."

checkdir_or_make SOURCE Source # Contains the source files that will be compiled into the build directory

checkdir_or_make SOURCE_INITRD Source/Initrd

checkdir_or_make SOURCE_KERNEL Source/Kernel

checkdir_or_make BUILD Build

checkdir_or_make BUILD_BOOT Build/Boot
