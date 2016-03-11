#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

xset r rate 300 44
xmodmap ~/.Xmodmap
xrdb -merge ~/.Xresources

while true; do
  xsetroot -solid "#20e0e5" -name "$(date +'%l:%M %Y-%m-%d') | Battery:$(acpi -b | cut -d "," -f 2) | Cpu: $(mpstat | tail -n 1 | awk '{print 100 - $13}') | wlp3s0 $(cat /sys/class/net/wlp3s0/operstate) | enp2s0 $(cat /sys/class/net/enp2s0/operstate)"
  xsetroot -cursor_name left_ptr
  sleep 1m
done &

while true; do
	find ~/.wallpapers -type f \( -name '*.jpg' -o -name '*.png' \) -print0 | shuf -n1 -z | xargs -0 feh --bg-scale
	sleep 1m
done &

xcompmgr -f &

exec dwm
