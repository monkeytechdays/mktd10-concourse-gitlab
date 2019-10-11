#!/usr/bin/env bash

set -eo pipefail

cp -r node_modules src/

pushd src
    npm run build || exit $?
popd

cp -R src/build/. out/
