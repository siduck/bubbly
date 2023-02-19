#!/bin/sh

install_dir=$(pwd)
mv "$install_dir" "$HOME/.local/share"

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
