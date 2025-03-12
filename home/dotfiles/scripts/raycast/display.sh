#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Change monitor setup
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🖥️
# @raycast.argument1 { "type": "text", "placeholder": "h or v" }

# check if one param
if [ "$#" -ne 1 ]; then
    echo "Usage: ${0} <mode>"
    exit 1
fi

if [ "${1}" == "h" ]; then
    displayplacer "id:60419E69-9ACC-4ACE-B575-648653490E10 res:3440x1440 hz:60 color_depth:8 enabled:true scaling:off origin:(0,0) degree:0" "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:1800x1169 hz:120 color_depth:8 enabled:true scaling:on origin:(-1800,271) degree:0"
elif [ "${1}" == "v" ]; then
    displayplacer "id:60419E69-9ACC-4ACE-B575-648653490E10 res:3440x1440 hz:60 color_depth:8 enabled:true scaling:off origin:(0,0) degree:0" "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:1800x1169 hz:120 color_depth:8 enabled:true scaling:on origin:(820,1440) degree:0"
else
    echo "Invalid mode"
    exit 1
fi
