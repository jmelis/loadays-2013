#!/bin/bash

sed -i 's/^:host.*/:host: 0.0.0.0/' /etc/one/sunstone-server.conf
iptables -F
setenforce 0
curl -s http://dev.opennebula.org/attachments/download/663/qemu.tar.gz \
    | sudo -u oneadmin tar xzf - -C /var/lib/one/remotes/vmm/
sed -i 's/ kvm"/ qemu"/' /etc/one/oned.conf
