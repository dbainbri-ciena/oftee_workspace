# OFTEE Workspace
[`OFTEE`](http://github.com/ciena/oftee) is an application that is used with an
SDN controller. `OFTEE` sits between and *OpenFlow device* and the *OpenFlow
controller* and *tees-off* *OpenFlow PacketIn* messages to external SDN
applications over various protocols, as well as provides a mechanism for
external SDN applications to send *OpenFlow PacketOut* messages back to the
managed switch.

This project is a sample workspace that has been used to help develop, test,
and experiment with `OFTEE`.

## Quick Start

### Start the VM
```
$ git clone http://github.com/dbainbri-ciena/oftee_workspace
$ cd oftee_workspace
$ vagrant up
$ vagrant ssh
```

### On the VM
```
$ cd /vagrant
$ make env
$ make images
$ make up
```

### Controller Support
This example contains support for both the Open Networking Operating System
(`ONOS`) and the OpenDaylight (`ODL`) controllers. To select which controller
is used an environment variable, `CONTROLLER` is used. If this variable is not
set the `ONOS` controller is used by default.

To use the `ODL` controller, for example, the same commands are run as above
with the exception in the `make up` command. That last command should instead
be:
```
$ CONTROLLER=odl make up
```
_All other command, including the test commands described later, are identical._

### Summary
After these commands are completed the test environment is up and running. The
test environment includes an Open Virtual Switch (`ovs`), OpenFlow controller
(`ONOS`), `oftee`, RADIUS server, DHCP Server, AAA SDN application, DHCP L3
proxy SDN application, and a client (host) from which the applications can be
tested. After make up is completed, the following Docker Swarm services should
be active:
```
$ docker service ls
ID                  NAME                MODE                REPLICAS            IMAGE                                 PORTS
xflhclbxkgq9        oftee_aaa           replicated          1/1                 aaa:local                             *:8005->8005/tcp
a5grjcir8tso        oftee_dhcpd         replicated          1/1                 networkboot/dhcpd:latest
icp1fuuffp2v        oftee_host          replicated          1/1                 host:local
13qd9yb8omkc        oftee_oftee         replicated          1/1                 oftee:local                           *:6654->6654/tcp, *:8000->8000/tcp
yy8viqa914ed        oftee_onos          replicated          1/1                 onosproject/onos:1.13.1               *:6653->6653/tcp, *:8101->8101/tcp, *:8181->8181/tcp
63bvz5og8g71        oftee_radius        replicated          1/1                 freeradius/freeradius-server:latest
ubnw94c56ptx        oftee_relay         replicated          1/1                 dhcp-relay:local                      *:5000->5000/tcp
```

And the Open Virtual Switch:
```
$ sudo ovs-vsctl show
a23463ec-349b-4c79-8050-c10ed1910298
    Bridge "br0"
        Controller "tcp:127.0.0.1:6654"
            is_connected: true
        Port "e22c270effc44_l"
            Interface "e22c270effc44_l"
        Port "br0"
            Interface "br0"
                type: internal
    ovs_version: "2.5.4"
```

### Testing
#### EAPOL / AAA
Issuing the `make wpa` command will execute a `wpa_supplicant` on the host
machine. This will issue EAPOL messages which will be converted to RADIUS
requests with EAPOL responses sent back to the client host. The output should
be similar to the following (_NOTE: the command will not automatically
terminate and `ctrl-c` will need to be used to stop the command_)
```
$ make wpa
docker exec -ti 9dfe4ed31d4efeaefd55a194febf1bad41a5ac84cd192ca74734468ec326d39b wpa_supplicant -i eth2 -D wired -c /etc/wpa_supplicant/wpa_supplicant.conf -ddd
wpa_supplicant v2.4
random: Trying to read entropy from /dev/random
Successfully initialized wpa_supplicant
Initializing interface 'eth2' conf '/etc/wpa_supplicant/wpa_supplicant.conf' driver 'wired' ctrl_interface 'N/A' bridge 'N/A'
Configuration file '/etc/wpa_supplicant/wpa_supplicant.conf' -> '/etc/wpa_supplicant/wpa_supplicant.conf'
Reading configuration file '/etc/wpa_supplicant/wpa_supplicant.conf'
ctrl_interface='/var/run/wpa_supplicant'
eapol_version=1
ap_scan=0
fast_reauth=1
Line: 5 - start of a new network block
.
.
.
EAP: EAP entering state SUCCESS
eth2: CTRL-EVENT-EAP-SUCCESS EAP authentication completed successfully
EAPOL: SUPP_BE entering state RECEIVE
EAPOL: SUPP_BE entering state SUCCESS
EAPOL: SUPP_BE entering state IDLE
```

#### DHCP L3 Relay
Issuing the `make dhcp` command will execute a `dhclient` on the host machine.
This will issue a DHCP request which will be proxied to the DHCP server with
responses sent back to the client host. The output should be similar to the
following (_NOTE: the command will not automatically
terminate and `ctrl-c` will need to be used to stop the command_)
```
$ make dhcp
docker exec -ti 9dfe4ed31d4efeaefd55a194febf1bad41a5ac84cd192ca74734468ec326d39b dhclient -4 -v -d -1 eth2
Internet Systems Consortium DHCP Client 4.3.3
Copyright 2004-2015 Internet Systems Consortium.
All rights reserved.
For info, please visit https://www.isc.org/software/dhcp/

RTNETLINK answers: Operation not permitted
Listening on LPF/eth2/92:ed:c8:01:0b:e9
Sending on   LPF/eth2/92:ed:c8:01:0b:e9
Sending on   Socket/fallback
DHCPDISCOVER on eth2 to 255.255.255.255 port 67 interval 3 (xid=0x51298e44)
DHCPDISCOVER on eth2 to 255.255.255.255 port 67 interval 5 (xid=0x51298e44)
DHCPREQUEST of 10.0.0.100 on eth2 to 255.255.255.255 port 67 (xid=0x448e2951)
DHCPOFFER of 10.0.0.100 from 10.0.0.12
DHCPACK of 10.0.0.100 from 10.0.0.12
RTNETLINK answers: Operation not permitted
mv: cannot move '/etc/resolv.conf.dhclient-new.44' to '/etc/resolv.conf': Device or resource busy
bound to 10.0.0.100 -- renewal in 269 seconds.
```

## Quick Stop

To stop the containers used for the demonstration the following command can be
used:
```
$ make down
```

If you want do destroy the `Vagrant MV`, first exist the VM login shell then
issue a `destroy` to `Vagrant`:
```
$ vagrant destroy -f
```

## Vagrant Machine
This project contains a `Vagrantfile` that will instantiate a virtual
machine (VM) that can be used as a test environment. While the specifics may
change over time the general characteristics of this VM are:
- Ubuntu LTS based
- OVS Switch Installed
- Docker installed
- Starts a single node Docker Swarm cluster
- ovs-docker tool installed (used to add containers to the OVS bridge)
- golang installed

The VM can be created using the [`Vagrant`](https://www.vagrantup.com/) tools.
Please see the associated web site for documentation about using the tools.

## Makefile
This project contains a `Makefile` that provides a mechanism to quickly
invoke useful commands for developing and testing. Simply running `make` will
display the possible targets (as listed below):
```
$ make
TARGET         DESCRIPTION
aaa.image      build the Docker image for the aaa SDN app
aaa.logs       tail -f the aaa SDN app logs
aaa.shell      start a shell in the aaa container
add-iface      add an interface to the ovs bridge for the host container
bridge         create the ovs bridge
del-bridge     delete the ovs bridge
deploy         start the Docker Swarm stack (all the containers)
dhcp           start a dhcp request in the host container
dhcp.logs      tail -f the DHCP server logs
dhcp.shell    start a shell in the DHCP server container
down           tear down everything
env            clone the source to oftee and aaa into workspace
flow-aaa-wait  push the EAP packet in flow repeated until success
flow-dhcp-wait push the DHCP packet in flow repeated until success
flow-wait      same as flows, but waits for success
flows          push the EAP and DHCP flows to packet in to the controller
host.image     build the Docker image for example client host
host.shell     start a shell in the host container
images         build or pull all required Docker imagges
oftee.image    build the Docker image for the oftee
oftee.logs     tail -f the oftee logs
onos.logs      tail -f the onos logs
pull.images    pull all standard images from dockhub.com
radius.logs    tail -f the radius logs
radius.shell   start a shell in the radius container
relay.image    build the Docker image for the DHCP L3 proxy app
relay.logs     tail -f the DHCP relay logs
relay.shell    start a shell in the DHCP relay container
undeploy       delete the Docker Swarm stack (all the containers)
up             bring up everything
wpa            start a wpa_supplicant in the host container
```

### Makefile Target Highlights
#### `env` - Clone `oftee` and `aaa` projects into workspace
This target help set up the development environment by cloning two projects
into the work space. This allows you to build the containers locally as well
as develop modifications to the projects.

#### `up` - Start everything
The `up` target turns up the workspace environment to the point you can start
issuing `EAPOL` and `DHCP` requests from the host (`oftee_host`).

#### `down` - Tears down everything
Self evident.

#### `wpa` - Starts the wpa_supplicant on host (`oftee_host`) container
This can be used to test / demonstrate the AAA application

### `dhcp` - Starts the `dhclient` on the host (`oftee_host`) containers
This can be used to test / demonstrate the DHCP L3 relay application
