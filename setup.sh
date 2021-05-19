#!/bin/bash

source "`dirname $0`/bin/functions"

[ -f "${LINSTRAP_DIR}/gradlew" ] || ln -sf "${LINSTRAP_DIR}/bin/gradle/gradlew" "${LINSTRAP_DIR}"

echo "Finished Setting Up Environment"
