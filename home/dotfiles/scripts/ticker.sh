#!/usr/bin/env bash

# check 1 argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <symbol>"
    exit 1
fi

symbol=$1

curl -s https://api.binance.com/api/v3/ticker/price | jq -r ".[] | select(.symbol == \"${symbol}\") | .price"
