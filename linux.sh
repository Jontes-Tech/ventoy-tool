#!usr/bin/env bash

# I am aware that this is objectively not a oneliner, but the install command is.
# I am also aware that this is not the best way to install the software, but it works.
# Thank you to all the people who have provided me with feedback for this.
# To make a pull request, please generate a sha512 hash of the script files changed and add them to scriptname.sha512. Thank you.

# Colors
Purple='\033[0;35m'
NC='\033[0m' # No Color
#

if [[ -t 0 ]]; then
    echo "We are in a terminal"
else
    echo 'Pipe detected! Please run this script from a file for security reasons. If you need piping, please use the older version of this script.'
    exit 1
fi

MY_PATH=$(pwd)
if [[ -z "$MY_PATH" ]] ; then
    exit 1  # fail
fi

script_checksum=$(sha512sum "$MY_PATH/$0" | awk '{ print $1 }')
script_github_checksum=$(curl -fsSL https://raw.githubusercontent.com/Jontes-Tech/ventoy-tool/master/linux.sha512)

echo "Script checksum: $script_checksum"
echo "Github checksum: $script_github_checksum"

if [ $script_checksum == $script_github_checksum ]; then
    echo "Checksum matched"
else
    echo "Checksum did not match"
    if [ $svcc == "true" ]; then
        echo "Skipping checksum check"
    else
        echo 'Checksum did not match. Set the $svcc variable to "true" to skip this check.'
        exit 1
    fi
    exit 1
fi

rm -rf /home/$USER/Ventoy/
printf "Welcome to ${Purple}VentoyTool${NC}!"
echo "This is a tool to help you to install Ventoy, made by Jonte"
echo "The program comes with ABSOLUTELY NO WARRENT NOR LIABILITY"
echo "This program is free software licensed under GPL 3.0, and you are welcome to redistribute it"
echo "---"
echo "Detecting your system..."
arch=$(uname -i)
echo "Checking latest version of Ventoy..."
ventoy_version=$(curl https://api.github.com/repos/Ventoy/ventoy/releases/latest -s | jq .tag_name -r)
echo "Downloading tarball..."
curl -fsSL https://github.com/ventoy/Ventoy/releases/download/$ventoy_version/ventoy-1.0.78-linux.tar.gz >/tmp/ventoy.tar.gz
echo "Comparing Checksums..."
local_checksum=$(echo $(sha256sum /tmp/ventoy.tar.gz) | sed 's/ .*//')
global_checksum=$(echo $(curl -fsSL https://github.com/ventoy/Ventoy/releases/download/$ventoy_version/sha256.txt) | grep --color=never ventoy-${ventoy_version:1}-linux.tar.gz | sed 's/ .*//')

if [ $local_checksum == $global_checksum ]; then
    echo "Checksum is correct"
else
    echo "Checksum is incorrect"
    exit 1
fi

echo "Extracting tarball..."
tar -xzvf /tmp/ventoy.tar.gz -C /tmp >>/tmp/ventoytool_untar.log
echo "Making Ventoy directory..."
mkdir /home/$USER/Ventoyrm -rf /tmp/ventoy.tar.gz
rm -rf /tmp/ventoy-${ventoy_version:1}
rm -f /tmp/ventoytool_untar.log
echo "Moving files..."
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

echo "Removing temporary files"
rm -rf /tmp/ventoy.tar.gz
rm -rf /tmp/ventoy-${ventoy_version:1}
rm -f /tmp/ventoytool_untar.log
echo "Done! - Launching VentoyGUI. To run VentoyGUI afterwards, run the following command:"
echo "/home/$USER/VentoyGUI"
~/Ventoy/VentoyGUI &