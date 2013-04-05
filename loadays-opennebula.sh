#!/bin/bash

# make sunstone listen in 0.0.0.0
sed -i 's/^:host.*/:host: 0.0.0.0/' /etc/one/sunstone-server.conf

# clear firewall
iptables -F

# disable SELinux
setenforce 0

# download QEMU drivers
curl -s http://dev.opennebula.org/attachments/download/663/qemu.tar.gz \
    | sudo -u oneadmin tar xzf - -C /var/lib/one/remotes/vmm/
sed -i 's/-r 0 kvm/-r 0 qemu/' /etc/one/oned.conf

# start required services
service messagebus start
service libvirtd start
