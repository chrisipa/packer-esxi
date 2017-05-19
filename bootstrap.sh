#!/bin/bash

# install additional packages
apt-get install -y open-vm-tools

# set locale 
locale-gen $1
update-locale LANG=$1
