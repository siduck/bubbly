#!/bin/dash

basedir="$HOME/.local/share/bubbly"

# variables
keycodes_list=$(awk '$1 == "keycode" {print $2,$4}' "$basedir/keycodes")

parse_keys() {
	read -r line

	key_code=$(echo "$line" | awk -F ' ' '/key press/ {print $NF}')
	key=$(echo "$keycodes_list" | awk -v keycode="$key_code" '$1 == keycode {print $2}')

	case $key in
	comma) key="," ;; period) key="." ;; slash) key="/" ;;
	minus) key="-" ;;
	esac
	
	# if [ "$previous_key2" = "Shift_L" ]; then
	# 	# handle symbols by numbers
	# 	case $key in
	# 	1) key='!' ;; 2) key='@' ;; 3) key='#' ;; 4) key='$' ;;
	# 	5) key='%' ;; 7) key='&' ;; 9) key='(' ;; 0) key=')' ;; /) key='?' ;;
	# 	esac
	# fi

	if [ ${#key} -gt 0 ]; then
		eww -c "$basedir/keystrokes" update keynow="$key"
	fi

	# previous_key2=$key
}

xinput test "12" | while parse_keys; do :; done
