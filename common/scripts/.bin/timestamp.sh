#!/usr/bin/env bash
set -euf -o pipefile

date +%s | tr -d '\n' | xclip -selection clipboard
