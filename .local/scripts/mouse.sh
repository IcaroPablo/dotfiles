mid=$(xinput list | grep /dev/wsmouse | awk '{print $4}' | sed 's/id=//')
mad=$(xinput list-props $mid | grep 'Device Accel Constant Deceleration ([0-9][0-9][0-9]):' | awk '{print $5}' | sed 's/[\(\): ]//g')

xinput set-prop $mid $mad $1
