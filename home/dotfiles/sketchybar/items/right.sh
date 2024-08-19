#!/usr/bin/env bash

sketchybar --add item clock right \
    --set clock update_freq=10 icon= script="$PLUGIN_DIR/clock.sh" \
    --add item volume right \
    --set volume script="$PLUGIN_DIR/volume.sh" \
    --subscribe volume volume_change \
    --add item battery right \
    --set battery update_freq=120 script="$PLUGIN_DIR/battery.sh" \
    --subscribe battery system_woke power_source_change \
    --add item user right
