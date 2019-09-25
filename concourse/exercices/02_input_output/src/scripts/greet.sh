#!/usr/bin/env ash

recipient='World'
[ -f inputs/recipient/recipient.txt ] && recipient="$(cat inputs/recipient/recipient.txt)"

echo "Hello ${recipient}" > outputs/message/message.txt
