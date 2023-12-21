#!/usr/bin/env bash

set -eu

if pgrep -f 'foot.*scratchpad'; then
    pkill -f 'foot.*scratchpad'
else
    foot -a floating_term tmux new-session -A -s scratchpad
fi
