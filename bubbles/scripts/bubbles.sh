#!/bin/dash

. /tmp/bubble_count

result=""

# generate list of chat bubbles
for i in $(seq 1 "$bubble_count"); do
	filename="/tmp/xkb$i"
	bytecount=$(wc -L <"$filename")

	width=$((bytecount * 10 + 40))
	cursor=$([ "$i" -eq "$bubble_count" ] && echo "_" || echo "")

	txt="$(cat "$filename") $cursor"

	if [ $width -gt 530 ]; then
    width=530
	fi

  css='background:white' # will add more properties here
	css=$([ "$i" -eq "$bubble_count" ] && echo "$css")

	result="${result} (label :class 'label' :text '$txt' :wrap true :width '$width' :xalign 0 :halign 'start' :style '$css') "
done

echo "(box :orientation 'v' :space-evenly false :class 'chats' $result )"
