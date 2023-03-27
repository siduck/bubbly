#!/bin/dash

basedir="$HOME/.local/share/bubbly"

# variables
keycodes_list=$(awk '$1 == "keycode" {print $2,$4}' "$basedir/keycodes")
filename="/tmp/xkb1"
bubble_count=1

parse_keys() {
	read -r line

	key_code=$(echo "$line" | awk -F ' ' '/key press/ {print $NF}')
	key=$(echo "$keycodes_list" | awk -v keycode="$key_code" '$1 == keycode {print $2}')

	case $key in
	space) key=" " ;; comma) key="," ;; period) key="." ;; slash) key="/" ;;
	minus) key="-" ;; BackSpace) truncate -s -1 "$filename" ;;

	Return)
		if [ -s "$filename" ] && [ "$(wc -L <"$filename")" -gt 1 ]; then
			if [ "$bubble_count" -eq 3 ]; then
				mv /tmp/xkb2 /tmp/xkb1 && mv /tmp/xkb3 /tmp/xkb2
				echo "export bubble_count=3" >/tmp/bubble_count
			else
				bubble_count=$((bubble_count + 1))
				echo "export bubble_count=$bubble_count" >/tmp/bubble_count
			fi
			filename="/tmp/xkb$bubble_count"
		fi
		;;
	esac

	if [ "$previous_key" = "Shift_L" ]; then
		case $key in
		# handle symbols by numbers
		1) key='!' ;; 2) key='@' ;; 3) key='#' ;; 4) key='$' ;;
		5) key='%' ;; 7) key='&' ;; 9) key='(' ;; 0) key=')' ;; /) key='?' ;;

		# capitalize
		[a-z]) key=$(echo "$key" | tr '[:lower:]' '[:upper:]') ;;
		esac
	fi

	if [ "$previous_key" = "Control_L" ] && [ "$key" = "Escape" ]; then
		eww -c "$basedir/bubbles" reload
		eww -c "$basedir/bubbles" close bubbly
    eww -c "$basedir/selector" update mode=''
		killall getkeys.sh
	fi

	# add letters only to the file
	if [ ${#key} -eq 1 ]; then
		echo -n "$key" >>"$filename"
	fi

	previous_key=$key
}

device=$(xinput --list --long | grep XIKeyClass | head -n 1 | grep -E -o '[0-9]+')

xinput test "$device" | while parse_keys; do :; done
