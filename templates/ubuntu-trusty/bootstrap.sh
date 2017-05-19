#!/bin/bash

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

# show IP addresses
ip addr show