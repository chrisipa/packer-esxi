#!/bin/bash

# configuration
inputrcFile="/etc/inputrc"
bashrcFile="/home/${osUsername}/.bashrc"

# update all packages
apt-get dist-upgrade -y

# install additional packages
apt-get install -y open-vm-tools

# set timezone
timedatectl set-timezone {osTimezone}

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

# show IP addresses
ip addr show