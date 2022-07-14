#!/bin/bash

# Colors
Purple='\033[0;35m'
NC='\033[0m' # No Color
#

rm -rf /home/$USER/Ventoy/
printf "Welcome to ${Purple}VentoyTool${NC}!"
echo "This is a tool to help you to install Ventoy, made by Jonte"
echo "The program comes with ABSOLUTELY NO WARRENT NOR LIABILITY"
echo "This program is free software licensed under GPL 3.0, and you are welcome to redistribute it"
echo "---"
echo "Detecting your system..."

arch=$(uname -i)
ventoy_version=$(curl https://api.github.com/repos/Ventoy/ventoy/releases/latest -s | jq .tag_name -r)
curl -fsSL https://github.com/ventoy/Ventoy/releases/download/$ventoy_version/ventoy-1.0.78-linux.tar.gz > /tmp/ventoy.tar.gz
local_checksum=$(echo $(sha256sum /tmp/ventoy.tar.gz) | sed 's/ .*//')
global_checksum=$(echo $(curl -fsSL https://github.com/ventoy/Ventoy/releases/download/$ventoy_version/sha256.txt) | grep --color=never ventoy-${ventoy_version:1}-linux.tar.gz | sed 's/ .*//')

if [ $local_checksum == $global_checksum ]; then
    echo "Checksum is correct"
else
    echo "Checksum is incorrect"
    exit 1
fi

tar -xzvf /tmp/ventoy.tar.gz -C /tmp >> /tmp/ventoytool_untar.log
mkdir /home/$USER/Ventoy
mv /tmp/ventoy-${ventoy_version:1}/ventoy /home/$USER/Ventoy/ventoy
mv /tmp/ventoy-${ventoy_version:1}/boot /home/$USER/Ventoy/boot
mv /tmp/ventoy-${ventoy_version:1}/tool /home/$USER/Ventoy/tool

if [ $arch == 'x86_64' ]; then
    echo "x86_64 detected"
    cp /tmp/ventoy-${ventoy_version:1}/VentoyGUI.x86_64 /home/$USER/Ventoy/VentoyGUI
    elif [ $arch == 'x86_32' ]; then
    cp /tmp/ventoy/${ventoy_version:1}/VentoyGUI.i386 /home/$USER/Ventoy/VentoyGUI
    echo "x32 detected"
    elif [ $arch == 'aarch64' ]; then
    cp /tmp/ventoy/${ventoy_version:1}/VentoyGUI.aarch64 /home/$USER/Ventoy/VentoyGUI
    echo "arm 64 detected"
else
    echo "System not supported, sorry :("
    exit 1
fi

echo "Done! - Launching VentoyGUI. To run VentoyGUI afterwards, run the following command:"
echo "/home/$USER/VentoyGUI"
~/Ventoy/VentoyGUI &