Packer ESXi VM Provisioner
==========================

# Overview

Simple bash script using packer for auto provisioning virtual machines to a VMWare ESXi server.
This script has been tested with VMWare ESXi version 6. The following operating systems are supported:

* Ubuntu 14.04 (ubuntu-trusty)

# Prerequisites

## ESXi Host

### SSH

* Enable SSH access on ESXi Host:

![Screenshot](https://raw.githubusercontent.com/chrisipa/packer-esxi/master/public/esxi-enable-ssh.png)

* Connect to ESXi host via SSH

### Guest IP Hack

* Enable Guest IP Hack:
  ```
  esxcli system settings advanced set -o /Net/GuestIPHack -i 1
  ```

### VNC Ports

* Change permissions on firewall configuration file:
  ```
  chmod 644 /etc/vmware/firewall/service.xml
  chmod +t /etc/vmware/firewall/service.xml
  ```

* Open firewall configuration file with vi:
  ```
  vi /etc/vmware/firewall/service.xml
  ```

* Add XML block for VNC ports to the end of the firewall configuration file:
  ```
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
  ```
  chmod 444 /etc/vmware/firewall/service.xml
  ```

* Restart firewall service:
  ```
  esxcli network firewall refresh
  ```

## Provisioner

* Install additional software packages:
  ```
  sudo apt-get install git packer sshpass
  ```

# Usage

* Checkout project from GitHub:
  ```
  git clone https://github.com/chrisipa/packer-esxi.git
  ```

* Change to project directory:
  ```
  cd packer-esxi
  ```

* Run packer-esxi command:
  ```
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

  ```
