Packer ESXi VM Provisioner
==========================

# Overview

Simple bash script using packer for auto provisioning virtual machines to a free VMWare ESXi server.
This script has been tested with VMWare ESXi version 6. At the moment the following guest operating systems are supported:

* Ubuntu 14.04 (ubuntu-trusty)

# Features

* Connect to ESXi server via SSH
* Upload operating system ISO to datastore
* Create virtual machine with specified parameters
* Power on virtual machine and executing unattended operating system installation
* Customize virtual machine with bash, ansible, chef, puppet and many more
* Power off virtual machine and cleanup resources
* Power on virtual machine to work with

# Prerequisites

## VM Network

* The virtual machine relies on an existing DCHP server on the specified vm network

## ESXi Host

### SSH

* Enable SSH access on ESXi Host:

![Screenshot](https://raw.githubusercontent.com/chrisipa/packer-esxi/master/public/esxi-enable-ssh.png)

* Connect to ESXi host via SSH

### Guest IP Hack

* Enable Guest IP Hack:
  ```bash
  esxcli system settings advanced set -o /Net/GuestIPHack -i 1
  ```

### VNC Ports

* Change permissions on firewall configuration file:
  ```bash
  chmod 644 /etc/vmware/firewall/service.xml
  chmod +t /etc/vmware/firewall/service.xml
  ```

* Open firewall configuration file with vi:
  ```bash
  vi /etc/vmware/firewall/service.xml
  ```

* Add XML block for VNC ports to the end of the firewall configuration file:
  ```xml
  <service id="1000">
    <id>packer-vnc</id>
    <rule id="0000">
      <direction>inbound</direction>
      <protocol>tcp</protocol>
      <porttype>dst</porttype>
      <port>
        <begin>5900</begin>
        <end>6000</end>
      </port>
    </rule>
    <enabled>true</enabled>
    <required>true</required>
  </service>
  ```

* Restore permissions on firewall configuration file:
  ```bash
  chmod 444 /etc/vmware/firewall/service.xml
  ```

* Restart firewall service:
  ```bash
  esxcli network firewall refresh
  ```

## Provisioner

* Install additional software packages:
  ```bash
  sudo apt-get install git sshpass
  ```

* Download and install packer from the website:
  ```bash
  wget https://releases.hashicorp.com/packer/1.0.0/packer_1.0.0_linux_amd64.zip
  sudo unzip packer_1.0.0_linux_amd64.zip -d /usr/local/bin
  rm -f packer_1.0.0_linux_amd64.zip
  ```

# Usage

## Plain Linux

* Checkout project from GitHub:
  ```bash
  git clone https://github.com/chrisipa/packer-esxi.git
  ```

* Change to project directory:
  ```bash
  cd packer-esxi
  ```

* Run packer-esxi command:
  ```bash
  ./packer-esxi --help

  --------------------------
  Packer ESXi VM Provisioner
  --------------------------

  Usage:
    ./packer-esxi [Options] <Args>

  Options:
    --esxi-server         <server>        The ESXi server
    --esxi-username       <username>      The ESXi username
    --esxi-password       <password>      The ESXi password
    --esxi-datastore      <datastore>     The ESXi datastore
    --vm-name             <name>          The VM name
    --vm-cores            <cores>         The number of virtual CPU Cores of the VM
    --vm-ram-size         <ram>           The RAM size of the VM (in MB)
    --vm-disk-size        <disk>          The Disk size of the VM (in GB)
    --vm-network          <network>       The Network name of the VM
    --os-type             <os>            The type of the OS
    --os-proxy            <proxy>         The proxy of the OS
    --os-username         <username>      The username of the OS
    --os-password         <password>      The password of the OS
    --os-domain           <domain>        The network domain of the OS
    --os-keyboard-layout  <layout>        The keyboard layout of the OS
    --os-locale           <locale>        The locale of the OS
    --os-timezone         <timezone>      The timezone of the OS
    --os-docker           <boolean>       Install docker engine in the OS
    --help                                Print this help text

  Example:
    ./packer-esxi --esxi-server esxi.my.domain \
       --esxi-username root \
       --esxi-password my-password \
       --esxi-datastore my-datastore \
       --vm-name my-vm \
       --vm-cores 1 \
       --vm-ram-size  512 \
       --vm-disk-size 10 \
       --vm-network "VM Network" \
       --os-type ubuntu-trusty \
       --os-proxy none | http://10.10.10.1:3128/ \
       --os-username my-username \
       --os-password my-password \
       --os-domain my.domain \
       --os-locale de_DE.UTF-8 \
       --os-keyboard-layout de \
       --os-timezone Europe/Berlin
       --os-docker true

  ```

## Docker

* Run via docker command:
  ```bash
  docker run --rm -v $HOME/.packer:/root/.packer -it chrisipa/packer-esxi
  ```

# Integrations

## Jenkins

* You can easily integrate the docker container into a parameterized build:

![Screenshot](https://raw.githubusercontent.com/chrisipa/packer-esxi/master/public/jenkins-integration.png)

* Just execute a shell command with the following content:
  ```bash
  #!/bin/bash +x

  # specify image name
  imageName="chrisipa/packer-esxi"

  # pull docker image from registry
  docker pull "$imageName"

  # execute docker run
  docker run --rm -v $HOME/.packer:/root/.packer -t "$imageName" \
  --esxi-server "$ESXI_SERVER" \
  --esxi-username "$ESXI_USERNAME" \
  --esxi-password "$ESXI_PASSWORD" \
  --esxi-datastore "$ESXI_DATASTORE" \
  --vm-name "$VM_NAME" \
  --vm-cores "$VM_CORES" \
  --vm-ram-size "$VM_RAM_SIZE" \
  --vm-disk-size "$VM_DISK_SIZE" \
  --vm-network "$VM_NETWORK" \
  --os-type "$OS_TYPE" \
  --os-proxy "$OS_PROXY" \
  --os-username "$OS_USERNAME" \
  --os-password "$OS_PASSWORD" \
  --os-domain "$OS_DOMAIN" \
  --os-locale "$OS_LOCALE" \
  --os-keyboard-layout "$OS_KEYBOARD_LAYOUT" \
  --os-timezone "$OS_TIMEZONE"
  --os-docker "$OS_DOCKER"
  ```
