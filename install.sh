#!/bin/sh

# copy default .bubblyrc config
cp -r ./keystrokes/config/.bubblyrc "$HOME/.config"

install_dir=$(pwd)
mv "$install_dir" "$HOME/.local/share"

# create desktop file
echo "[Desktop Entry]
Version=1.0
Type=Application
Name=Bubbly
Comment=Screencast keys & generate on-screen chat bubbles
Exec=/home/$USER/.local/share/bubbly/start.sh
Icon=preferences-desktop-keyboard-shortcuts
Categories=Utility;" >"$HOME/.local/share/applications/bubbly.desktop"

# uses xinput to get active keyboard ( device ID )
echo "press any key to get device name"

get_device() {
	dir=$(mktemp -d)
	trap 'rm -rf -- "$dir"; kill -- -$$' EXIT
	cd "$dir"

	xinput --list --id-only |
		while read -r id; do
			if xinput --list-props "$id" | grep -qE '^\s+Device Node.*/dev/input/event'; then
				xinput test "$id" >"$id" 2>/dev/null &
			fi
		done

	while sleep 0.1; do
		for file in *; do
			if [ -s "$file" ]; then
				echo "export device_name=$file" >device_name
				exit
			fi
		done
	done
}

get_device
