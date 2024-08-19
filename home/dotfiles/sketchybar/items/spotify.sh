#!/usr/bin/env bash

sketchybar --add event spotify_change com.spotify.client.PlaybackStateChanged
sketchybar --add item spotify right \
    --set spotify \
    background.padding_left=$GAP \
    script="$PLUGIN_DIR/spotify.sh" \
    --subscribe spotify spotify_change mouse.clicked

SPOTIFY_ICON_SIZE=19
SPOTIFY_CONTROL_GAP=0

sketchybar --add item spotify.next right \
    --set spotify.next \
    icon=󰒭 icon.font.size=$SPOTIFY_ICON_SIZE \
    label.padding_left=0 label.padding_right=7 \
    background.drawing=off \
    background.padding_right=0 \
    script="$PLUGIN_DIR/spotify.sh" \
    --subscribe spotify.next mouse.clicked

sketchybar --add item spotify.playpause right \
    --set spotify.playpause \
    icon= \
    icon.font.size=15 \
    icon.y_offset=1 icon.padding_left=9 \
    label.padding_left=0 label.padding_right=7 \
    background.drawing=off \
    background.padding_right=$SPOTIFY_CONTROL_GAP \
    script="$PLUGIN_DIR/spotify.sh" \
    --subscribe spotify.playpause mouse.clicked

sketchybar --add item spotify.back right \
    --set spotify.back \
    icon=󰒮 \
    label.padding_left=0 label.padding_right=7 \
    icon.padding_left=8 icon.font.size=$SPOTIFY_ICON_SIZE \
    background.drawing=off \
    background.padding_right=$SPOTIFY_CONTROL_GAP \
    script="$PLUGIN_DIR/spotify.sh" \
    --subscribe spotify.back mouse.clicked

sketchybar --add bracket spotify_controls \
    spotify.next spotfy.playpause spotify.back
