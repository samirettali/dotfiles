#!/usr/bin/env bash

if [ "$SENDER" = "aerospace_workspace_change" ]; then
  prevapps=$(aerospace list-windows --workspace "$PREV_WORKSPACE")
  if [ "${prevapps}" != "" ]; then
    sketchybar --set space.$PREV_WORKSPACE drawing=on
  else
    sketchybar --set space.$PREV_WORKSPACE drawing=off
  fi

  sketchybar --set space.$FOCUSED_WORKSPACE drawing=on
fi
