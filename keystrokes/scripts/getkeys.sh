#!/bin/dash

basedir="$HOME/.local/share/bubbly"
. "$basedir/device_name"

# variables
keycodes_list=$(awk '$1 == "keycode" {print $2,$4}' "$basedir/keycodes")
previous_key=''
timeout=$(date '+%M%S')

keys_file=/tmp/bubbly_keys

parse_keys() {
	read -r line

	key_code=$(echo "$line" | awk -F ' ' '/key press/ {print $NF}')
	key=$(echo "$keycodes_list" | awk -v keycode="$key_code" '$1 == keycode {print $2}')

	# shorten some key names
	case $key in
	comma) key="," ;; period) key="." ;; slash) key="/" ;;
	minus) key="-" ;; BackSpace) key="" ;; Escape) key="Esc" ;;
	bracketleft) key="[" ;; bracketright) key="]" ;; equal) key="=" ;;
	Control_L | Control_RL) key="Ctrl" ;; apostrophe) key='"' ;;
	esac

	if [ "$previous_key" = "Shift_L" ]; then
		# handle symbols
		case $key in
		1) key='!' ;; 2) key='@' ;; 3) key='#' ;; 4) key='$' ;;
		5) key='%' ;; 7) key='&' ;; 9) key='(' ;; 0) key=')' ;; /) key='?' ;;

		# capitalize
		[a-z]) key=$(echo "$key" | tr '[:lower:]' '[:upper:]') ;;
		esac
	fi

	if [ ${#key} -gt 0 ] && [ "$key" != "Shift_R" ] && [ "$key" != "Shift_L" ]; then
		key=$(echo "$key" | sed 's/_.*//') # rm _txt suffix for some keys like alt_r -> alt etc
		echo -n " $key" >>$keys_file
		keys=$(cat $keys_file)

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

	previous_key=$key
}

xinput test "$device" | while parse_keys; do :; done &

# if the user doesnt type for 3 seconds then hide eww widget
check_keypress_timeout() {
	while true; do
		timenow=$(date '+%M%S')
		time_diff=$((timenow - timeout))

		if [ "$time_diff" -gt 3 ]; then
			eww -c "$basedir/keystrokes" update keynow="$result"
			echo -n "" >$keys_file
		fi

		sleep 2
	done
}

check_keypress_timeout &
