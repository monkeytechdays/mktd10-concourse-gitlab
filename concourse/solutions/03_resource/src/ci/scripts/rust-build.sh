#!/usr/bin/env bash

read version <versions/version.txt

pushd src
    cargo build
popd

mv "src/target/debug/${project_name}" "bin/${project_name}-${version}"
