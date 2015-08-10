#!/usr/bin/env bash

manifest="../metadata/manifest.yml"

cd "$( dirname "${0}" )"
cd "$( pwd -P )"

function getVersion() {
    sed -n 's/^Cartridge-Version:[^0-9.]*\([0-9.]*\)[^0-9.]*$/\1/p' "${manifest}"
}

oldVersion=$( getVersion )

wget -q -O - "https://dist.torproject.org/" \
| sed -n 's/.*>tor-\([0-9.]*\).tar.gz<.*/\1/p' \
| ./manifestgen/dist/build/manifestgen/manifestgen "${oldVersion}" \
> "${manifest}"

git commit -v ../metadata/manifest.yml
git tag "tor-openshift-$( getVersion )"
