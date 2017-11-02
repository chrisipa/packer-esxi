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

# install docker engine?
if [ "${osDocker}" == "true" ]
then

    # install additional helper packages
    apt-get install -y apt-transport-https ca-certificates curl linux-image-extra-$(uname -r) linux-image-extra-virtual software-properties-common

    # add gpg key
    curl -x "${osProxy}" -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

    # add apt sources to list
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    # update package repos
    apt-get update

    # install docker community edition
    apt-get install -y docker-ce

    # allow execution of docker command without sudo
    gpasswd -a ${osUsername} docker
    
    # download docker-compose and make executable
    curl -x "${osProxy}" -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
    # download docker-compose-wrapper and make executable
    curl -x "${osProxy}" -L https://raw.githubusercontent.com/chrisipa/docker-compose-wrapper/master/docker-compose-wrapper -o /usr/local/bin/docker-compose-wrapper
    chmod +x /usr/local/bin/docker-compose-wrapper
    
    # if proxy is set
    if [ "${osProxy}" != "" ]
    then
        # set proxy for docker daemon
        echo -e '\n\nexport http_proxy="${osProxy}"' >> /etc/default/docker
        
        # restart docker daemon
        service docker restart
    fi    
fi

# get default IP address
ipAddress="$(ip route get 8.8.8.8 | head -1 | cut -d' ' -f8)"

# show how to login via ssh
echo ""
echo "---------"
echo "SSH login"
echo "---------"
echo "ssh ${osUsername}@${ipAddress}"
echo ""
