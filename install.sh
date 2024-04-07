#!/bin/bash

set -e

# Get correct distro-dependent installation directories 
loc_plugin=$(qtpaths --plugin-dir)
loc_desktop=$(kf5-config --path services|awk -F ':' '{print $NF}')
loc_config=$(qtpaths --install-prefix)/share/config

# Fetch and unpack packaged files
if [ ! -f krunner-symbols-*-Linux.tar.gz ]; then
    wget https://github.com/domschrei/krunner-symbols/releases/download/1.1.0/krunner-symbols-1.1.0-Linux.tar.gz
fi
pkg=$(echo krunner-symbols-*-Linux.tar.gz|awk '{print $NF}')
mkdir -p build
tar xzvf "$pkg" -C build --strip-components=1
cd build

# Fetch current version
version=$(jq -r '.KPlugin.Version' symbols.json)

# Install files
echo "Installing plugin files into system directories ..."
sudo cp krunner_symbols.so "$loc_plugin"/
sudo cp plasma-runner-symbols.desktop "$loc_desktop"/
sudo mkdir -p "$loc_config"
sudo cp krunner-symbolsrc krunner-symbols-full-unicode-index "$loc_config/"

echo "Installation successful. Restarting krunner for the changes to take effect."
if pgrep -x krunner > /dev/null; then
    killall krunner
fi
