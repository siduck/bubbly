#!/bin/dash

basedir="$HOME/.local/share/bubbly"

chat() {
	eww -c "$basedir/selector" update mode=Chats
	eww -c "$basedir/selector" close selector
	"$basedir/start.sh" chat
}

keystrokes() {
	eww -c "$basedir/selector" update mode=Keystrokes
	eww -c "$basedir/selector" close selector
	"$basedir/start.sh" keystrokes
}

"$@"
