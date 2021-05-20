# This software may be modified and distributed under the terms
# of the MIT license.  See the LICENSE file for details.
#
# Copyright (c) 2021 Amelia Sara Greene <barelyaprincess@gmail.com>
# Copyright (c) 2021 Penoaks Publishing LLC <development@penoaks.com>
#
#!/bin/bash

[ $LINSTRAP_DIR ] || LINSTRAP_DIR="${0%/*}"

. ${LINSTRAP_DIR}/func
. ${LINSTRAP_DIR}/fontworks

[ -d "${LINSTRAP_DIR}/workdir" ] || mkdir -p "${LINSTRAP_DIR}/workdir"
[ -f "${LINSTRAP_DIR}/gradlew" ] || ln -sf "${LINSTRAP_DIR}/bin/gradle/gradlew" "${LINSTRAP_DIR}"

FG_DEFAULT=$_CYAN

. ${LINSTRAP_DIR}/header

echo "Checking Environment..."

echo -n "  X86_64? "
ARCH=`uname -m`
[ ${ARCH} == "x86_64" ] || error "@f&4Nope! Only X86_64 is at present supported.&r"
echo "yes"

printf "  Running as root? "
[ `whoami` == "root" ] || error "@f&4Nope! This script must be executed with root privileges.&r"
echo "yes"

printf "  What is the window size? "
if [ $LINES && $COLUMNS ]; then
    echo "&2 $LINES x $COLUMNS "

printf "  Is `checkwinsize` enabled? "
[[ ! `shopt checkwinsize` == *"on"* ]] && error "@f&4Nope! We need to know the screen size. You can set the LINES or COLUMNS vars to ignore this error."
echo "yes"

echo
echo "LinStrap Directory: ${LINSTRAP_DIR}"
echo
