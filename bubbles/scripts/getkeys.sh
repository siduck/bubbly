#!/bin/dash

basedir="$HOME/.local/share/bubbly"

# variables
keycodes_list=$(awk '$1 == "keycode" {print $2,$4}' "$basedir/keycodes")
filename="/tmp/xkb1"
bubble_count=1
shift_active=0
previous_key=''
caps_lock_active=0

parse_keys() {
	read -r line

	key_code=$(echo "$line" | awk -F ' ' '/key press/ {print $NF}')
	key=$(echo "$keycodes_list" | awk -v keycode="$key_code" '$1 == keycode {print $2}')

  # shorten some key names
	case $key in
		space) key=" " ;; 
		comma) key="," ;; 
		period) key="." ;; 
    slash) key="/" ;;
		minus) key="-" ;; 
    apostrophe) key="'" ;;
    equal) key="=" ;;
    grave) key="\`" ;;
    apostrophe) key="\'" ;;
    semicolon) key=";" ;;
    bracketleft) key="[" ;;
    bracketright) key="]" ;;
		BackSpace) truncate -s -1 "$filename" ;;
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
	
	# Check if Shift or Caps Lock is active
	if [ "$key" = "Shift_L" ] || [ "$key" = "Shift_R" ]; then
		shift_active=1
	elif [ "$key" = "Caps_Lock" ]; then
		caps_lock_active=$((1 - caps_lock_active)) # Toggle Caps Lock state
	elif [ "$key" = "KeyRelease" ]; then
    if [ "$previous_key" = "Shift_L" ] || [ "$previous_key" = "Shift_R" ]; then
        shift_active=0
    fi
    $previous_key='' # clear previous key after release
	fi

	if [ "$shift_active" -eq 1 ] && [ "$previous_key" = "Shift_L" ] || [ "$previous_key" = "Shift_R" ]; then
		case $key in
		    1) key='!' ;;
		    2) key='@' ;;
		    3) key='#' ;;
		    4) key='$' ;;
		    5) key='%' ;;
		    6) key='^' ;;
		    7) key='&' ;;
		    8) key='*' ;;
		    9) key='(' ;;
		    0) key=')' ;;
        /) key='?' ;;
        -) key='_' ;;
        "'") key='"' ;;
        =) key='+' ;;
        ;) key=':' ;;
        [) key='{' ;;
        ]) key='}' ;;
        backslash) key='|' ;;
        ,) key='<' ;;
        .) key='>' ;;
        \`) key="~" ;;
		esac
	fi

  # Handle caps lock for letter casing
  if [ "$caps_lock_active" -eq 1 ]; then
    case $key in
      [a-z]) key=$(echo "$key" | tr '[:lower:]' '[:upper:]') ;;
    esac
  else
    case $key in
      [A-Z]) key=$(echo "$key" | tr '[:upper:]' '[:lower:]') ;;
    esac
  fi

  # If Shift isn't active, convert uppercase to lowercase
  if [ "$shift_active" -eq 0 ] && [ "$caps_lock_active" -eq 0 ]; then
    case $key in
      [A-Z]) key=$(echo "$key" | tr '[:upper:]' '[:lower:]') ;;
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
