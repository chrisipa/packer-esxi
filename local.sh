#!/bin/sh

# local configuration options

# Note: modify at your own risk!  If you do/use anything in this
# script that is not part of a stable API (relying on files to be in
# specific places, specific tools, specific output, etc) there is a
# possibility you will end up with a broken system after patching or
# upgrading.  Changes are not supported unless under direction of
# VMware support.

# configuration
firewallConfigFile="/etc/vmware/firewall/service.xml"

# enable guest ip hack
esxcli system settings advanced set -o /Net/GuestIPHack -i 1

# change permissions on firewall config file
chmod 644 "$firewallConfigFile" 
chmod +t "$firewallConfigFile" 

# remove config root end tag from firewall config file
sed -i -e 's|</ConfigRoot>||g' "$firewallConfigFile"

# add xml block for vnc ports to the end of the firewall config file
cat <<EOT >> "$firewallConfigFile"
  <!-- Ports opened for Packer VNC commands -->
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
</ConfigRoot>
EOT

# restore permissions on firewall config file
chmod 444 "$firewallConfigFile"

# restart firewall service
esxcli network firewall refresh

exit 0
