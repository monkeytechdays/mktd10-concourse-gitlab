#!/usr/bin/env bash

set -eo pipefail

[[ -d node_modules ]] && {
    cp -r node_modules src/
}

pushd src
    npm install
popd

cp -R src/node_modules/. node_modules/
