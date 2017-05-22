#!/bin/bash

# configuration
inputrcFile="/etc/inputrc"
bashrcFile="/home/${osUsername}/.bashrc"

# update all packages
apt-get dist-upgrade -y

# install additional packages
apt-get install -y open-vm-tools

# set timezone
timedatectl set-timezone ${osTimezone}

# set locale
locale-gen ${osLocale}
update-locale LANG=${osLocale}

# set keyboard layout
sed -i 's|'XKBMODEL=.*'|'XKBMODEL=pc105'|g' /etc/default/keyboard
sed -i 's|'XKBLAYOUT=.*'|'XKBLAYOUT=${osKeyboardLayout}'|g' /etc/default/keyboard

# add history completion
echo "" >> "$inputrcFile"
echo '"\e[5~": history-search-backward' >> "$inputrcFile"
echo '"\e[6~": history-search-forward' >> "$inputrcFile"

# add default aliases
echo "" >> "$bashrcFile"
echo "alias l='ls -altrh'" >> "$bashrcFile"
echo "alias ..='cd ..'" >> "$bashrcFile"

# get default IP address
ipAddress="$(ip route get 8.8.8.8 | head -1 | cut -d' ' -f8)"

# show how to login via ssh
echo ""
echo "---------"
echo "SSH login"
echo "---------"
echo "ssh ${osUsername}@${ipAddress}"
echo ""