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
