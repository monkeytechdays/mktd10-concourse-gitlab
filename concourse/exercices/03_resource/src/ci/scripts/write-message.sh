#!/usr/bin/env ash

read random </dev/urandom
version="${#random}"

echo "Message #${version}" > "messages/message-${version}.txt"
