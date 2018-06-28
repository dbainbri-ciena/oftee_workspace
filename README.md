# OFTEE Workspace
[`OFTEE`](http://github.com/ciena/oftee) is an application that is used with an
SDN controller. `OFTEE` sits between and *OpenFlow device* and the *OpenFlow
controller* and *tees-off* *OpenFlow PacketIn* messages to external SDN
applications over various protocols, as well as provides a mechanism for
external SDN applications to send *OpenFlow PacketOut* messages back to the
managed switch.

This project is a sample workspace that has been used to help develop, test,
and experiment with `OFTEE`.

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
env            clone the source to oftee and aaa into workspace
host.image     build the Docker image for example client host
oftee.image    build the Docker image for the oftee
aaa.image      build the Docker image for the aaa SDN app
pull.images    pull all standard images from dockhub.com
images         build or pull all required Docker imagges
bridge         create the ovs bridge
del-bridge     delete the ovs bridge
add-iface      add an interface to the ovs bridge for the host container
deploy         start the Docker Swarm stack (all the containers)
undeploy       delete the Docker Swarm stack (all the containers)
flows          push the EAP flow to packet in to the controller
flow-wait      same as flows, but waits for success
up             bring up everything
down           tear down everything
host.shell     start a shell in the host container
wpa            start a wpa_supplicant in the host container
oftee.logs     tail -f the oftee logs
aaa.logs       tail -f the aaa SDN app logs
onos.logs      tail -f the onos logs
radius.logs    tail -f the radius logs
```

### Makefile Target Highlights
#### `env` - Clone `oftee` and `aaa` projects into workspace
This target help set up the development environment by cloning two projects
into the work space. This allows you to build the containers locally as well
as develop modifications to the projects.

#### `up` - Start everything
The `up` target turns up the workspace environment to the point you can start
issuing `EAPOL` requests from the host (`oftee_host`).

#### `down` - Tears down everything
Self evident.

#### `wpa` - Starts the wpa_supplicant on host (`oftee_host`) container
Self evident.
