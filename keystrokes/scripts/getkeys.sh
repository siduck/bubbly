#!/bin/dash

basedir="$HOME/.local/share/bubbly"

. "$HOME/.config/bubbly/keystrokes"

gradient=$("$basedir/keystrokes/scripts/gen_gradient.sh" "$keystrokes_bg")

# variables
keycodes_list=$(awk '$1 == "keycode" {print $2,$4}' "$basedir/keycodes")
previous_key=''

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
	semicolon) key=";" ;;
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

		# if [ $keys = "Ctrl Esc" ]; then
		if [ "$keys" = " Ctrl Esc" ]; then
			eww -c "$basedir/bubbles" close bubbly
			eww -c "$basedir/keystrokes" close keystrokes
      eww -c "$basedir/selector" update mode=''
			killall getkeys.sh
		fi

		key_widgets_list=""
		recent_words=$(echo "$keys" | rev | cut -d' ' -f-"$keystrokes_limit" | rev) # get last 3 only
		words_len=$(echo "$recent_words" | wc -w)
		index=0

		for word in $recent_words; do
			css=""
			index=$((index + 1))

			if [ $index -eq "$words_len" ]; then
				css="color: #EF8891; background: #282c34"
			fi

			# active_style=""
			key_widget="(label :class 'label' :style '$css' :text '$word')"
			key_widgets_list=" $key_widgets_list $key_widget "
		done

		result="(box :spacing 10 :style '$gradient' :class 'keybox' :space-evenly false $key_widgets_list )"
		eww -c "$basedir/keystrokes" update keys="$result"

		echo -n "$(date '+%s')" >/tmp/bubbly_chat_timeout
	fi

	previous_key=$key
}

device=$(xinput --list --long | grep XIKeyClass | head -n 1 | grep -E -o '[0-9]+')

xinput test "$device" | while parse_keys; do :; done &

# if the user doesnt type for 2 seconds then hide eww widget
check_keypress_timeout() {
	while true; do
		timeout=$(cat /tmp/bubbly_chat_timeout)
		timenow=$(date '+%s')
		time_diff=$((timenow - timeout))

		if [ "$time_diff" -ge 1 ]; then
			eww -c "$basedir/keystrokes" update keys=" "
			eww -c "$basedir/keystrokes" reload
			echo -n "" >$keys_file
		fi

		sleep 1
	done
}

check_keypress_timeout &
