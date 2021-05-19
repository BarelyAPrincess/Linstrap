#!/bin/bash

[ $LINSTRAP_DIR ] || LINSTRAP_DIR="${0%/*}"

. ${LINSTRAP_DIR}/startup.sh

[ -f "${LINSTRAP_DIR}/gradlew" ] || ln -sf "${LINSTRAP_DIR}/bin/gradle/gradlew" "${LINSTRAP_DIR}"

[ -d "${LINSTRAP_DIR}/workdir" ] || mkdir -p "${LINSTRAP_DIR}/workdir"

echo "Finished Setting Up Environment"
