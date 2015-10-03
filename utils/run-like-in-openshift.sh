#!/usr/bin/env bash

# Script to emulate OpenShift environment for testing

set -eu

if [ -z "${TMP:-}" ]; then
    TMP=$( mktemp -d )
else
    mkdir -p "${TMP}"
fi

export OPENSHIFT_LOG_DIR="${TMP}/LOG/"
test -e "${OPENSHIFT_LOG_DIR}" \
|| mkdir -p "${OPENSHIFT_LOG_DIR}"

export OPENSHIFT_DATA_DIR="${TMP}/DATA/"
test -e "${OPENSHIFT_DATA_DIR}" \
|| mkdir -p "${OPENSHIFT_DATA_DIR}"

export OPENSHIFT_REPO_DIR="${TMP}/REPO/"
test -e "${OPENSHIFT_REPO_DIR}" \
|| git clone . "${OPENSHIFT_REPO_DIR}"


export OPENSHIFT_CARTRIDGE_SDK_BASH="${TMP}/SDK"
cat > "${OPENSHIFT_CARTRIDGE_SDK_BASH}" <<\__EOF__
function set_env_var() {
    mkdir -p "${3}"
    echo "${2}" > ${3}/${1}
}
function client_result() {
    echo "${@}"
}
__EOF__

### {{{ APP (PARTLY) SPECIFIC STUFF ###########################################
export OPENSHIFT_TOR_DIR="${TMP}/APP/"
test -e "${OPENSHIFT_TOR_DIR}" \
|| {
    mkdir -p "${OPENSHIFT_TOR_DIR}"
    cp -r bin usr "${OPENSHIFT_TOR_DIR}"
    find . -name *.erb | xargs -n1 bash -c 'DEST=${OPENSHIFT_TOR_DIR}${1/.erb/}; mkdir -p "$( dirname "${DEST}" )"; erb ${1} > ${DEST}' --
}

for name in ${OPENSHIFT_TOR_DIR}/env/*; do
    export $(basename "${name}")=$( cat "${name}" )
done

if ! [ -z "${OPENSHIFT_TOR_PATH_ELEMENT}" ]; then
    PATH="${OPENSHIFT_TOR_PATH_ELEMENT}:${PATH}"
fi
### }}} APP (PARTLY) SPECIFIC STUFF ###########################################

"${@}"

echo "TMP=\"${TMP}\""
