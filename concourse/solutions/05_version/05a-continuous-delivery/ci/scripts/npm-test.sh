#!/usr/bin/env bash

set -eo pipefail

cp -r node_modules src/

pushd src
    npm run test || exit $?
popd
