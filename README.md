# Install OpenNebula

Initial Setup
-------------

### Install the OpenNebula packages

    # cd /etc/yum.repos.d/
    # curl -O ...
    # yum install opennebula-*

### Patches for this demo

Make Sunstone listen in 0.0.0.0

    # sed -i 's/^:host.*/:host: 0.0.0.0/' /etc/one/sunstone-server.conf

Stop the firewall

    # iptables -F

Disable SELinux

    # setenforce 0

Patch for QEMU

    $ curl -s http://dev.opennebula.org/attachments/download/663/qemu.tar.gz | sudo -u oneadmin tar xzf - -C /var/lib/one/remotes/vmm/
    $ sed -i 's/ kvm"/ qemu"/' /etc/one/oned.conf

Change the hostname (optional)

### Start the services

    # service opennebula start
    # service opennebula-sunstone start

Quick Tour
----------

Login as oneadmin

    # su - oneadmin

### CLI

$ one[TAB]
$ oneuser list

### Sunstone

Get user/password

    $ cat ~/.one/one_auth

Get IP (EC2 users)

    $ curl ifconfig.me

Login into sunstone: http://{ip}:9869

Hosts
-----

Add the host key

    $ ssh-keyscan `hostname` >> .ssh/known_hosts

Register the host

    $ onehost create `hostname` -i kvm -v kvm -n dummy
    ID: 0

    $ onehost list
      ID NAME            CLUSTER   RVM      ALLOCATED_CPU      ALLOCATED_MEM STAT
       0 ip-10-33-137-22 -           0                  -                  - on

    $ onehost show 0
    HOST 0 INFORMATION
    ID                    : 0
    NAME                  : ip-10-33-137-224
    CLUSTER               : -
    STATE                 : MONITORED
    IM_MAD                : kvm
    VM_MAD                : kvm
    VN_MAD                : dummy
    LAST MONITORING TIME  : 04/04 21:52:24

    HOST SHARES
    TOTAL MEM             : 0K
    USED MEM (REAL)       : 0K
    USED MEM (ALLOCATED)  : 0K
    TOTAL CPU             : 0
    USED CPU (REAL)       : 0
    USED CPU (ALLOCATED)  : 0
    RUNNING VMS           : 0

    MONITORING INFORMATION


    VIRTUAL MACHINES

        ID USER     GROUP    NAME            STAT UCPU    UMEM HOST             TIME


Datastores
----------

