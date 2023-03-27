#!/bin/sh

cd "$HOME/.local/share"
git clone https://github.com/siduck/bubbly --depth 1

cp -r bubbly/config "$HOME/.config/bubbly"

# create desktop file
echo "[Desktop Entry]
Version=1.0
Type=Application
Name=Bubbly
Comment=Screencast keys & generate on-screen chat bubbles
Exec=/home/$USER/.local/share/bubbly/start.sh
Icon=preferences-desktop-keyboard-shortcuts
Categories=Utility;" >"$HOME/.local/share/applications/bubbly.desktop"
