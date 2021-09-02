# vim: set ft=sh

export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true '
export _JAVA_AWT_WM_NONREPARENTING=1
export XSECURELOCK_NO_COMPOSITE=1

start_dwm() {
  ~/.bin/setup_display

  eval $(ssh-agent)

# Set background
  [[ -f "${HOME}/.fehbg" ]] && ~/.fehbg &
# hsetroot -solid "#1d1f21"

# Compositor
  picom -b --experimental-backends --backend glx

# Notification daemon
  dunst &

# Network manager
  nm-applet &

# Screenshots
  flameshot &

# Autolock screen
  xss-lock -n /usr/lib/xsecurelock/dimmer -l -- xsecurelock &

# Set time to autolock
  xset s 300 5

# # Increase keyboard speed
  xset r rate 200 60

# Dwm status bar
  slstatus &

# Start dwm
  exec dwm
}

# start_dwm
exec ssh-agent xmonad
