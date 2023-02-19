#!/bin/dash

basedir="$HOME/.local/share/bubbly"

chat() {
	# rm old files
	rm -f /tmp/xkb* /tmp/bubble_count
	echo "export bubble_count=1" >/tmp/bubble_count

	eww -c "$basedir/bubbles" open bubbly &

	"$basedir/bubbles/scripts/getkeys.sh" &
}

keystrokes() {
	eww -c "$basedir/keystrokes" open keystrokes
	"$basedir/keystrokes/scripts/getkeys.sh"
}

if [ $# -eq 0 ]; then
	echo "available arguments : chats and keystrokes"
fi

"$@"