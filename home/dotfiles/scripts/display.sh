#!/usr/bin/env bash

# check if one param
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <mode>"
    exit 1
fi

if [ "$1" == "horizontal" ]; then
    displayplacer "id:D8CA49E5-1E37-4D88-9E77-EEFD5DA28A29 res:3440x1440 hz:60 color_depth:8 enabled:true scaling:off origin:(0,0) degree:0" "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:1800x1169 hz:120 color_depth:8 enabled:true scaling:on origin:(-1800,271) degree:0"
elif [ "$1" == "vertical" ]; then
    displayplacer "id:D8CA49E5-1E37-4D88-9E77-EEFD5DA28A29 res:3440x1440 hz:60 color_depth:8 enabled:true scaling:off origin:(0,0) degree:0" "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:1800x1169 hz:120 color_depth:8 enabled:true scaling:on origin:(820,1440) degree:0"
else
    echo "Invalid mode"
    exit 1
fi
