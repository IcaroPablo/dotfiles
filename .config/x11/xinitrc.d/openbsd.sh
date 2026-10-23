# OpenBSD, sourced by .xinitrc: the wsmouse pointer's acceleration
mid=$(xinput list | grep /dev/wsmouse | awk '{print $4}' | sed 's/id=//')
mad=$(xinput list-props "$mid" | grep 'Device Accel Constant Deceleration' | awk '{print $5}' | sed 's/[():]//g')
[ -n "$mid" ] && [ -n "$mad" ] && xinput set-prop "$mid" "$mad" 2
unset mid mad
