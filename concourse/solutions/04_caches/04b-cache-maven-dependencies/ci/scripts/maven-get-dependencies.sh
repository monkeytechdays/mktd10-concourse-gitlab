#!/usr/bin/env bash

set -eo pipefail

basedir="$(pwd)"

[[ -d "$HOME/.m2" ]] || mkdir -p "$HOME/.m2"
[[ -d "$HOME/.m2/repository" ]] && rm -rf "$HOME/.m2/repository"
[[ -d "${basedir}/m2/repository" ]] && mv "${basedir}/m2/repository" "$HOME/.m2/"
mv "${basedir}/ci/maven-settings.xml" "$HOME/.m2/settings.xml"

pushd "${basedir}/src"
    mvn org.apache.maven.plugins:maven-dependency-plugin:3.1.1:go-offline -DoverWriteIfNewer=false
popd

cp -R "$HOME/.m2/repository" "${basedir}/m2"
