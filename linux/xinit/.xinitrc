# vim: set ft=sh

export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true '
export _JAVA_AWT_WM_NONREPARENTING=1
export XSECURELOCK_NO_COMPOSITE=1

~/.bin/setup_display

eval $(ssh-agent)

# Set background
[[ -f "${HOME}/.fehbg" ]] && ~/.fehbg &

# Compositor
picom -b --experimental-backends --backend glx

# Notification daemon
dunst &

# Network manager
nm-applet &

# Screenshots
flameshot &

# Slack
slack &

# Autolock screen
xss-lock -n /usr/lib/xsecurelock/dimmer -l -- xsecurelock &

# Set time to autolock
xset s 300 5

# Increase keyboard speed
xset r rate 200 60

# Dwm status bar
slstatus &

# Start dwm
exec dwm
