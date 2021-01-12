# vim: set ft=sh
export QT_SCALE_FACTOR=2
export XSECURELOCK_NO_COMPOSITE=1
eval $(ssh-agent)
xrandr --dpi 220
sh ~/.fehbg &
# picom -b --experimental-backends --backend glx
compton --backend glx
dunst &
xset s 300 5
xss-lock -n /usr/lib/xsecurelock/dimmer -l -- xsecurelock &
xautolock -locker slock -time 10 -corners '0-0+' -cornerredelay 3600 -cornerdelay 1 &
xset r rate 200 60
exec dwm
