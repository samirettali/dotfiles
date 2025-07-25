#!/usr/bin/env bash

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
	echo "Not in a git repository"
	exit 1
fi

os=$(uname)
commit_hash=""

# Check the operating system
# TODO: refactor this using nix to directly use the correct command
case $os in
Linux)
	if [ -n "$WAYLAND_DISPLAY" ]; then
		# Wayland
		commit_hash=$(git log --format=%H -n 1)
		echo -n "$commit_hash" | wl-copy
	else
		# X11
		commit_hash=$(git log --format=%H -n 1)
		echo -n "$commit_hash" | xclip -selection clipboard
	fi
	;;
Darwin)
	commit_hash=$(git log --format=%H -n 1)
	echo -n "$commit_hash" | pbcopy
	;;
*)
	echo "Unsupported operating system: $os"
	exit 1
	;;
esac

echo "Latest commit hash copied to clipboard: $commit_hash"
