#!/bin/dash

basedir="$HOME/.local/share/bubbly"
. "$basedir/device_name"

# variables
keycodes_list=$(awk '$1 == "keycode" {print $2,$4}' "$basedir/keycodes")

timeout=$(date '+%M%S')

parse_keys() {
	read -r line

	key_code=$(echo "$line" | awk -F ' ' '/key press/ {print $NF}')
	key=$(echo "$keycodes_list" | awk -v keycode="$key_code" '$1 == keycode {print $2}')

	if [ ${#key} -gt 0 ]; then
		key=$(echo "$key" | sed 's/_.*//') # rm _txt suffix for some keys like alt_r -> alt etc
		echo -n " $key" >> "$basedir/keystrokes/keys"
		keys=$(cat "$basedir/keystrokes/keys")

		key_widgets_list=""

		recent_words=$(echo "$keys" | rev | cut -d' ' -f-3 | rev) # get last 3 only

		index=0

		for word in $recent_words; do
			css=""

			index=$((index + 1))

			if [ $index -eq 3 ]; then
				css="border: 2px solid #e06c75; color: #e06c75;"
			fi

			# active_style=""
			key_widget="(label :class 'label' :style '$css' :text '$word')"
			key_widgets_list=" $key_widgets_list $key_widget "
		done

		result="(box :spacing 10 :class 'keybox' :space-evenly false $key_widgets_list )"
		eww -c "$basedir/keystrokes" update keynow="$result"

		timeout=$(date '+%M%S')

		recent_words=""
	fi
}

xinput test "$device" | while parse_keys; do :; done &

# if the user doesnt type for 3 seconds then 
check_keypress_timeout() {
	while true; do
		timenow=$(date '+%M%S')
		time_diff=$((timenow - timeout))

		if [ "$time_diff" -gt 3 ]; then
			eww -c "$basedir/keystrokes" update keynow="$result"
			echo -n "" > "$basedir/keystrokes/keys"
		fi

		sleep 2
	done
}

check_keypress_timeout &
