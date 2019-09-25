#!/usr/bin/env bash

pushd src
    cargo build || exit $?
popd

mv src/target/debug/my-rust-app bin/
