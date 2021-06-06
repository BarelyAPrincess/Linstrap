#!/bin/bash

LC_ALL=C

THE_FILE=`realpath ${1}`
TMP_FILE="$THE_FILE.c2h"

[ -f "${TMP_FILE}" ] || cp -v "${THE_FILE}" "${TMP_FILE}"

echo -n "Making kernel config human friendly \"$THE_FILE\"..."

sed -Ei 's/^[# ]{0,2}(CONFIG_[A-Z0-9_]*) is not set$/\1=def/' ${THE_FILE}
sed -Ei 's/^(CONFIG_[A-Z0-9_]*)=y$/\1=yes/' ${THE_FILE}
sed -Ei 's/^(CONFIG_[A-Z0-9_]*)=n$/\1=no/' ${THE_FILE}
sed -Ei 's/^(CONFIG_[A-Z0-9_]*)=m$/\1=mod/' ${THE_FILE}
sed -Ei '/^\s*$/d' ${THE_FILE}
sed -Ei  '/^#/d' ${THE_FILE}

sort ${THE_FILE} --output ${THE_FILE}

echo "FINISHED"
