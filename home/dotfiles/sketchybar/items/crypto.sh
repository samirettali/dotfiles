#!/usr/bin/env bash

sketchybar --add item crypto.price right \
    --subscribe crypto.price crypto_price_change \
    --set crypto.price \
    background.color=0x44ffffff \
    background.corner_radius=5 \
    background.height=20 \
    background.drawing=off \
    script="$PLUGIN_DIR/crypto.sh"
