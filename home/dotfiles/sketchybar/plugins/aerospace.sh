#!/usr/bin/env bash

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set "${NAME}" icon.color=0xffffffff
else
    sketchybar --set "${NAME}" icon.color=0x44ffffff
fi
