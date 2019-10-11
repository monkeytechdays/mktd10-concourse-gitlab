#!/usr/bin/env bash

set -eo pipefail


basedir="$(pwd)"
[[ -d "$HOME/.m2" ]] || mkdir -p "$HOME/.m2"
[[ -d "$HOME/.m2/repository" ]] && rm -rf "$HOME/.m2/repository"
[[ -d "${basedir}/m2/repository" ]] && mv "${basedir}/m2/repository" "$HOME/.m2/"
mv "${basedir}/ci/maven-settings.xml" "$HOME/.m2/settings.xml"

cp -R "src/." "out/"
version="$(cat version/version)"
pushd "out"
    rc=0
    mvn versions:set "-DnewVersion=${version}" || rc=$?
    mvn dependency:go-offline || rc=$?
popd

cp -R "$HOME/.m2/repository" "${basedir}/m2"

exit "$rc"
