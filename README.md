# Install OpenNebula

Initial Setup
-------------

### Install the OpenNebula packages

    # cd /etc/yum.repos.d/
    # curl -O https://nazar.karan.org/results/opennebula/_opennebula.repo
    # yum install opennebula-server opennebula-sunstone opennebula-node-kvm

### Patches for this demo

Just run this command and let me handle the rest for you...

    $ curl -L http://bit.ly/loadays-opennebula | bash -s

This script will:

* make sunstone listen in 0.0.0.0
* disable the firewall
* disable SELinux
* download QEMU drivers
* start required services

Quick Tour
----------

### OpenNebula Services

    # service opennebula start
    # service opennebula-sunstone start

### CLI

Login as oneadmin

    # su - oneadmin

OpenNebula commands?

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
    LAST MONITORING TIME  : 04/04 22:33:58

    HOST SHARES
    TOTAL MEM             : 1.6G
    USED MEM (REAL)       : 198.2M
    USED MEM (ALLOCATED)  : 0K
    TOTAL CPU             : 100
    USED CPU (REAL)       : 1
    USED CPU (ALLOCATED)  : 0
    RUNNING VMS           : 0

    MONITORING INFORMATION
    ARCH="x86_64"
    CPUSPEED="2000"
    FREECPU="98.7"
    FREEMEMORY="1492428"
    HOSTNAME="ip-10-33-137-224"
    HYPERVISOR="kvm"
    MODELNAME="Intel(R) Xeon(R) CPU           E5645  @ 2.40GHz"
    NETRX="0"
    NETTX="0"
    TOTALCPU="100"
    TOTALMEMORY="1695376"
    USEDCPU="1.3"
    USEDMEMORY="202948"

    VIRTUAL MACHINES

        ID USER     GROUP    NAME            STAT UCPU    UMEM HOST             TIME

Datastores
----------

List available Datastores

    $ onedatastore list

Show the default Datastore

    $ onedatastore show 0
    $ onedatastore show 0 -x

Change the configuration

    $ onedatastore update default
    SAFE_DIRS="/"

Image
-----

Register a new image from the marketplace

    $ onemarket list|grep ttylinux|grep kvm
     4fc76a938fb81d3517000003                                     ttylinux - kvm  OpenNebula.org

    $ onemarket show 4fc76a938fb81d3517000003|grep href
          "href": "http://marketplace.c12g.com/appliance/4fc76a938fb81d3517000003/download"

    $ oneimage create --name ttylinux --path http://marketplace.c12g.com/appliance/4fc76a938fb81d3517000003/download -d default
    ID: 0

    $ oneimage list
      ID USER       GROUP      NAME            DATASTORE     SIZE TYPE PER STAT RVMS
       0 oneadmin   oneadmin   ttylinux        default        40M OS    No rdy     0

TODO: Do the same using Sunstone

Network
-------

Create a bridge (as root)

    # brctl addbr br0
    # ifconfig br0 192.168.0.1/24 up

Create a network

    $ cat private-network.one
    NAME = private
    TYPE = fixed
    BRIDGE = br0

    LEASES = [ IP = 192.168.0.10 ]
    LEASES = [ IP = 192.168.0.11 ]
    LEASES = [ IP = 192.168.0.12 ]
    LEASES = [ IP = 192.168.0.13 ]
    LEASES = [ IP = 192.168.0.14 ]
    LEASES = [ IP = 193.168.0.15 ]

    $ onevnet create private-network.one
    ID: 0

    $ onevnet show 0
    VIRTUAL NETWORK 0 INFORMATION
    ID             : 0
    NAME           : private
    USER           : oneadmin
    GROUP          : oneadmin
    CLUSTER        : -
    TYPE           : FIXED
    BRIDGE         : br0
    VLAN           : No
    USED LEASES    : 0

    PERMISSIONS
    OWNER          : um-
    GROUP          : ---
    OTHER          : ---

    VIRTUAL NETWORK TEMPLATE


    FREE LEASES
    LEASE=[ MAC="02:00:c0:a8:00:0a", IP="192.168.0.10", IP6_LINK="fe80::400:c0ff:fea8:a", USED="0", VID="-1" ]
    LEASE=[ MAC="02:00:c0:a8:00:0b", IP="192.168.0.11", IP6_LINK="fe80::400:c0ff:fea8:b", USED="0", VID="-1" ]
    LEASE=[ MAC="02:00:c0:a8:00:0c", IP="192.168.0.12", IP6_LINK="fe80::400:c0ff:fea8:c", USED="0", VID="-1" ]
    LEASE=[ MAC="02:00:c0:a8:00:0d", IP="192.168.0.13", IP6_LINK="fe80::400:c0ff:fea8:d", USED="0", VID="-1" ]
    LEASE=[ MAC="02:00:c0:a8:00:0e", IP="192.168.0.14", IP6_LINK="fe80::400:c0ff:fea8:e", USED="0", VID="-1" ]
    LEASE=[ MAC="02:00:c1:a8:00:0f", IP="193.168.0.15", IP6_LINK="fe80::400:c1ff:fea8:f", USED="0", VID="-1" ]

    VIRTUAL MACHINES

        ID USER     GROUP    NAME            STAT UCPU    UMEM HOST             TIME


Other interesting onevnet commands:

* rmleases {vnetid} {ip}: Removes a lease from the Virtual Network
* addleases {vnetid} {ip} [{mac}]: Adds a lease to the Virtual Network
* hold {vnetid} {ip}: Holds a Virtual Network lease, marking it as used
* release {vnetid} {ip}: Releases a Virtual Network lease on hold

Virtualization
--------------

Create a VM template

    $ onetemplate create --name tty --cpu 1 --memory 64 --disk ttylinux \
        --nic private --vnc --dry
    NAME="tty"
    CPU=1.0
    MEMORY=64
    DISK=[
      IMAGE="ttylinux"
    ]
    NIC=[
      NETWORK="private"
    ]
    GRAPHICS=[ TYPE="vnc", LISTEN="0.0.0.0" ]

    $ onetemplate create --name tty --cpu 1 --memory 64 --disk ttylinux \
        --nic private --vnc
    ID: 0

Instantiate a VM

    $ onetemplate instantiate 0 --name myname
    VM ID: 0

    $ onevm list
    ID USER     GROUP    NAME            STAT UCPU    UMEM HOST             TIME
     0 oneadmin oneadmin tty-1           runn   32     64M ip-10-33-1   0d 00h02

    $ onevm show 0
    VIRTUAL MACHINE 0 INFORMATION
    ID                  : 0
    NAME                : tty-0
    USER                : oneadmin
    GROUP               : oneadmin
    STATE               : ACTIVE
    LCM_STATE           : RUNNING
    RESCHED             : No
    HOST                : ip-10-33-137-224
    START TIME          : 04/05 00:15:28
    END TIME            : -
    DEPLOY ID           : one-0

    VIRTUAL MACHINE MONITORING
    USED CPU            : 26
    USED MEMORY         : 64M
    NET_RX              : 5K
    NET_TX              : 3K

    PERMISSIONS
    OWNER               : um-
    GROUP               : ---
    OTHER               : ---

    VM DISKS
     ID TARGET IMAGE                               TYPE SAVE SAVE_AS
      0 hda    ttylinux                            file   NO       -

    VM NICS
     ID NETWORK              VLAN BRIDGE       IP              MAC
      0 private                no br0          192.168.0.10    02:00:c0:a8:00:0a
                                               fe80::400:c0ff:fea8:a

    VIRTUAL MACHINE HISTORY
     SEQ HOST                 REASON           START            TIME     PROLOG_TIME
       0 ip-10-33-137-224     none    04/05 00:15:53    0d 00h03m19s    0d 00h00m01s

    VIRTUAL MACHINE TEMPLATE
    CPU="1"
    GRAPHICS=[
      LISTEN="0.0.0.0",
      PORT="5901",
      TYPE="vnc" ]
    MEMORY="64"
    NAME="one-0"
    TEMPLATE_ID="0"
    VMID="0"

    $ onevm show -x 0|grep '<IP>'
      <IP><![CDATA[192.168.0.10]]></IP>

    $ ping -c1 192.168.0.10
    PING 192.168.0.10 (192.168.0.10) 56(84) bytes of data.
    64 bytes from 192.168.0.10: icmp_seq=1 ttl=64 time=0.376 ms

    --- 192.168.0.10 ping statistics ---
    1 packets transmitted, 1 received, 0% packet loss, time 0ms
    rtt min/avg/max/mdev = 0.376/0.376/0.376/0.000 ms

    $ ssh 192.168.0.10 -l root

Authentication & Authorization & Accounting
-------------------------------------------

1. Show User create dialog: Multiple auth mechanisms
2. Show ACL Rules
3. Show Template permissions
4. Create an user and show quotas / historical usage
