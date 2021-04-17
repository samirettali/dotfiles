# vim: set ft=sh

setup_xps_screen() {
  if [[ ! -z $(xrandr | grep '^DP1 connected') ]]; then
    xrandr --output eDP1 --off --output DP1 --primary --mode 3440x1440 --pos 0x0 --rotate normal --output DP2 --off --output HDMI1 --off --output HDMI2 --off --output VIRTUAL1 --off
  else
    export QT_SCALE_FACTOR=2
    xrandr --dpi 220
    xrdb -merge "${HOME}/.Xresources"
  fi
}

if [[ $(hostname) -eq "xps" ]]; then
  setup_xps_screen
fi

export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true '

export XSECURELOCK_NO_COMPOSITE=1
eval $(ssh-agent)

# Set background
sh ~/.fehbg &

# Compositor
# picom -b --experimental-backends --backend glx

# Notification daemon
dunst &

# Autolock screen
xss-lock -n /usr/lib/xsecurelock/dimmer -l -- xsecurelock &

# Set time to autolock
xset s 300 5

# Increase keyboard speed
xset r rate 200 60

# slstatus &

# Start dwm
exec i3
