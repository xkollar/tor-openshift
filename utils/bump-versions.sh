#!/usr/bin/env bash

declare -r manifest="../metadata/manifest.yml"
declare -r binsetup="../bin/setup"

cd "$( dirname "${0}" )"
cd "$( pwd -P )"

function getCartridgeVersion() {
    sed -n 's/^Cartridge-Version:[^0-9.]*\([0-9.]*\)[^0-9.]*$/\1/p' "${manifest}"
}

oldVersion=$( getCartridgeVersion )

wget -q -O - "https://dist.torproject.org/" \
| sed -n 's/.*>tor-\([0-9.]*\).tar.gz<.*/\1/p' \
| ./manifestgen/dist/build/manifestgen/manifestgen "${oldVersion}" \
> "${manifest}"

latestTorVersion=$( sed -n 's/^Version: '\''\(.*\)'\''/\1/p' "${manifest}" )
sed -i 's/^\(declare version=\).*/\1"'"${latestTorVersion}"'"/' "${binsetup}"

newVersion=$( getCartridgeVersion )

git commit -v "${manifest}" "${binsetup}" \
&& git tag "tor-openshift-${newVersion}"
