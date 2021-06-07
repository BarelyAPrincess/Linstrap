#!/bin/bash

TMPFILE="/tmp/`basename ${1}`"
TMPFILE_LEFT="${TMPFILE}_left"
TMPFILE_RIGHT="${TMPFILE}_right"

# This is a hacking, there are better ways to do this.

cat "${1}" | sed -E 's/[# ]+([A-Z0-9_]+) is not set/\1=UNSET/' | sed -E 's/y$/YES/' | sed -E 's/=n$/NO/' | sed -E 's/=/ = /' | egrep -v "^#|^$" > "${TMPFILE_LEFT}"
cat "${2}" | sed -E 's/[# ]+([A-Z0-9_]+) is not set/\1=UNSET/' | sed -E 's/y$/YES/' | sed -E 's/=n$/NO/' | sed -E 's/=/ = /' | egrep -v "^#|^$" > "${TMPFILE_RIGHT}"

sdiff "${TMPFILE_LEFT}" "${TMPFILE_RIGHT}"
