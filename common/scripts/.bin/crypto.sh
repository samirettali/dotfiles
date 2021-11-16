#!/usr/bin/env zsh
set -euf
set -o pipefail

response=$(curl -s -H "Authorization: Bearer ${NOMICS_TOKEN}" https://api.nomics.com/v1/currencies/ticker)

function get_price() {
    currency="${1}"
    rate=$(echo "${response}" | jq -r --arg currency "$currency" '.[] | select(.currency==$currency) | .price')
    printf %.0f "${rate}"
}

btc_price=$(get_price "BTC")
eth_price=$(get_price "ETH")
dot_price=$(get_price "DOT")
ens_price=$(get_price "ENS")
echo -n "BTC: ${btc_price}"
echo -n " | ETH: ${eth_price}"
echo -n " | DOT: ${dot_price}"
echo -n " | ENS: ${ens_price}"
