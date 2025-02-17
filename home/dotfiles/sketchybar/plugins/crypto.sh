#!/usr/bin/env bash

echo "DEBUG: running crypto.sh PRICE=${PRICE}" >>/tmp/crypto_price.log

sketchybar --set "$NAME" label="${PRICE}$"
