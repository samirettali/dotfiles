#!/usr/bin/env bash
set -x

shopt -s nullglob globstar

typeit=0
if [[ $1 == "--type" ]]; then
	typeit=1
	shift
fi

if [[ -n $WAYLAND_DISPLAY ]]; then
	dmenu=bemenu
	xdotool="ydotool type --file -"
elif [[ -n $DISPLAY ]]; then
	dmenu=dmenu
	xdotool="xdotool type --clearmodifiers --file -"
else
	echo "Error: No Wayland or X11 display detected" >&2
	exit 1
fi

prefix=${PASSWORD_STORE_DIR-~/.password-store}
password_files=("$prefix"/**/*.gpg)
password_files=("${password_files[@]#"$prefix"/}")
password_files=("${password_files[@]%.gpg}")

password=$(printf '%s\n' "${password_files[@]}" | "$dmenu" "$@")

[[ -n $password ]] || exit

if [[ $typeit -eq 0 ]]; then
	pass show -c "$password" 2>/dev/null
else
	pass show "$password" | {
		IFS= read -r pass
		printf %s "$pass"
	} | $xdotool
fi
