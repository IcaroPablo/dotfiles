#!/usr/bin/env bash

# Change this depending on your battery in /sys/class/power_supply/
battery="BAT0";
update_network_info=true

get_uptime(){
	echo -e "uptime: $(uptime --pretty | sed -e 's/up //g' -e 's/ days/d/g' -e 's/ day/d/g' -e 's/ hours/h/g' -e 's/ hour/h/g' -e 's/ minutes/m/g' -e 's/, / /g') |"
}

get_RAM_usage() {
	echo "RAM: $(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g | sed s/,/./g) |"
}

get_wifi_connection() {
	echo "wifi: $(nmcli | sed -n '1p' | sed 's/wlp3s0: connected to //') |"
}

get_screen_brightness() {
    echo "screen: $(xbacklight -get | sed 's/\..*$//')% |"
}

get_sound_volume () {
	echo "sound: $(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}') |"
}

get_battery_status() {
    if [ -d /sys/class/power_supply/$battery ]; then
    	current_battery_charge="$(cat "/sys/class/power_supply/$battery/capacity")"
		current_battery_status="$(cat "/sys/class/power_supply/$battery/status")"
		echo "battery: "$current_battery_charge"% ("$current_battery_status") |"
	
		if [ $current_battery_charge -lt "10" -a $current_battery_status = "Discharging" ]; then
			# st -e sh -c 'figlet bateria fraca recarregue imediatamente; bash' 
			# figlet bateria fraca recarregue imediatamente | dmenu -l 25
			{ echo ""; figlet -c bateria fraca recarregue imediatamente; } | tr "\n" "\n" | dmenu -l 19
			
			#show_message="0"
		fi
	else
		echo ""
	fi

}

get_datetime() {
    date +"%a %d %b %Y | %I:%M %p (%Z GMT)"
}

get_status() {
	echo " $(get_uptime) $(get_RAM_usage) $(get_wifi_connection) $(get_screen_brightness) $(get_sound_volume) $(get_battery_status) $(get_datetime)";
}

set_status_to_bar() {
    xsetroot -name "$(get_status)"
}

echo "pid of this process is $$"
touch "$HOME/.cache/barpid" && echo $$ > $HOME/.cache/barpid
echo "printing the pid above to the file $HOME/.cache/barpid" 
echo "use it to send the signal 30 and refresh the bar whenever you want with the command:"
echo "kill -30 \$(cat \$HOME/.cache/barpid)"

trap "set_status_to_bar" 30

while true
do
	set_status_to_bar
	sleep 1 & wait
done
