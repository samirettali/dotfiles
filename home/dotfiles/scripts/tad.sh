#!/usr/bin/env bash

set -euo pipefail

ts=$(date +%s)
d="$HOME/.throw-away/$ts"
mkdir -p "$d"
(
	cd "$d"
	zsh -c tmux
)
rm -rf "$d"
