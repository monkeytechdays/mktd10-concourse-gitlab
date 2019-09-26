#!/usr/bin/env ash

read random </dev/urandom
version="${#random}"

echo "${version}" > "versions/version.txt"
