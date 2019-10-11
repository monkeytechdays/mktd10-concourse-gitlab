#!/usr/bin/env bash

set -eo pipefail

cp -R "src/." "out/"

version="$(cat version/version)"
pushd "out"
    npm  --no-git-tag-version version "${version}" || exit $?
popd
