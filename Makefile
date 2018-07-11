DOCKER_BUILD_ARGS=$(NO_CACHE) --quiet --force-rm --rm


.PHONY: all
all:
	@echo "TARGET         DESCRIPTION"
	@echo "aaa.image      build the Docker image for the aaa SDN app"
	@echo "aaa.logs       tail -f the aaa SDN app logs"
	@echo "aaa.shell      start a shell in the aaa container"
	@echo "add-iface      add an interface to the ovs bridge for the host container"
	@echo "bridge         create the ovs bridge"
	@echo "del-bridge     delete the ovs bridge"
	@echo "deploy         start the Docker Swarm stack (all the containers)"
	@echo "dhcp           start a dhcp request in the host container"
	@echo "dhcp.logs      tail -f the DHCP server logs"
	@echo "dhcp.shell    start a shell in the DHCP server container"
	@echo "down           tear down everything"
	@echo "env            clone the source to oftee and aaa into workspace"
	@echo "flow-aaa-wait  push the EAP packet in flow repeated until success"
	@echo "flow-dhcp-wait push the DHCP packet in flow repeated until success"
	@echo "flow-wait      same as flows, but waits for success"
	@echo "flows          push the EAP and DHCP flows to packet in to the controller"
	@echo "host.image     build the Docker image for example client host"
	@echo "host.shell     start a shell in the host container"
	@echo "images         build or pull all required Docker imagges"
	@echo "oftee.image    build the Docker image for the oftee"
	@echo "oftee.logs     tail -f the oftee logs"
	@echo "onos.logs      tail -f the onos logs"
	@echo "pull.images    pull all standard images from dockhub.com"
	@echo "radius.logs    tail -f the radius logs"
	@echo "radius.shell   start a shell in the radius container"
	@echo "relay.image    build the Docker image for the DHCP L3 proxy app"
	@echo "relay.logs     tail -f the DHCP relay logs"
	@echo "relay.shell    start a shell in the DHCP relay container"
	@echo "undeploy       delete the Docker Swarm stack (all the containers)"
	@echo "up             bring up everything"
	@echo "wpa            start a wpa_supplicant in the host container"

.PHONY: env
env:
	mkdir -p oftee/src/github.com/ciena aaa/src/github.com/ciena
	git clone http://github.com/ciena/oftee oftee/src/github.com/ciena/oftee
	git clone http://github.com/dbainbri-ciena/oftee-sdn-aaa-app aaa/src/github.com/ciena/aaa
	git clone http://github.com/dbainbri-ciena/oftee-sdn-dhcp-l3-relay-app dhcp-relay

.PHONY: host.image
host.image:
	docker build $(DOCKER_BUILD_ARGS) -t host:local -f example/docker/Dockerfile.host example/docker

.PHONY: oftee.image
oftee.image:
	docker build $(DOCKER_BUILD_ARGS) -t oftee:local -f oftee/src/github.com/ciena/oftee/Dockerfile oftee/src/github.com/ciena/oftee

.PHONY: aaa.image
aaa.image:
	docker build $(DOCKER_BUILD_ARGS) -t aaa:local -f aaa/src/github.com/ciena/aaa/Dockerfile aaa/src/github.com/ciena/aaa

.PHONY: relay.image
relay.image:
	docker build $(DOCKER_BUILD_ARGS) -t dhcp-relay:local -f dhcp-relay/Dockerfile dhcp-relay

.PHONY: pull.images
pull.images:
	docker pull freeradius/freeradius-server:latest
	docker pull onosproject/onos:1.13.1
	docker pull networkboot/dhcpd:latest

.PHONY: images
images: host.image oftee.image aaa.image relay.image pull.images

.PHONY: bridge
bridge:
	sudo sudo ovs-vsctl list-br | grep -q br0 || sudo ovs-vsctl add-br br0
	sudo ovs-vsctl set-controller br0 tcp:127.0.0.1:6654

.PHONY: del-bridge
del-bridge:
	sudo ovs-vsctl del-br br0

.PHONY: add-iface
add-iface:
	sudo ovs-docker add-port br0 eth2 $(shell ./utils/cid oftee_host)

.PHONY: deploy
deploy:
	docker stack deploy -c example/oftee-stack.yml oftee

.PHONY: flows
flows:
	curl -sSL -H 'Content-type: application/json' http://karaf:karaf@127.0.0.1:8181/onos/v1/flows/of:$(shell sudo ovs-ofctl show br0 | grep dpid | awk -F: '{print $$NF}')  -d@example/aaa_in.json
	curl -sSL -H 'Content-type: application/json' http://karaf:karaf@127.0.0.1:8181/onos/v1/flows/of:$(shell sudo ovs-ofctl show br0 | grep dpid | awk -F: '{print $$NF}')  -d@example/dhcp_in.json

.PHONY: flow-aaa-wait
flow-aaa-wait:
	@bash -c \
		curl --fail -sSL -H 'Content-type: application/json' http://karaf:karaf@127.0.0.1:8181/onos/v1/flows/of:$(shell sudo ovs-ofctl show br0 2>/dev/null | grep dpid | awk -F: '{print $$NF}')  -d@example/aaa_in.json 2>/dev/null 1>/dev/null; \
		while [ $$? -ne 0 ]; do \
		  echo "waiting for ONOS to accept flow requests ..."; \
		  sleep 3; \
		  curl --fail -sSL -H 'Content-type: application/json' http://karaf:karaf@127.0.0.1:8181/onos/v1/flows/of:$(shell sudo ovs-ofctl show br0 2>/dev/null | grep dpid | awk -F: '{print $$NF}')  -d@example/aaa_in.json 2>/dev/null 1>/dev/null; \
		done;

.PHONY: flow-dhcp-wait
flow-dhcp-wait:
	@bash -c \
                curl --fail -sSL -H 'Content-type: application/json' http://karaf:karaf@127.0.0.1:8181/onos/v1/flows/of:$(shell sudo ovs-ofctl show br0 2>/dev/null | grep dpid | awk -F: '{print $$NF}')  -d@example/dhcp_in.json 2>/dev/null 1>/dev/null; \
                while [ $$? -ne 0 ]; do \
                  echo "waiting for ONOS to accept flow requests ..."; \
                  sleep 3; \
                  curl --fail -sSL -H 'Content-type: application/json' http://karaf:karaf@127.0.0.1:8181/onos/v1/flows/of:$(shell sudo ovs-ofctl show br0 2>/dev/null | grep dpid | awk -F: '{print $$NF}')  -d@example/dhcp_in.json 2>/dev/null 1>/dev/null; \
                done;

.PHONY: flow-wait
flow-wait: flow-aaa-wait flow-dhcp-wait

.PHONY: undeploy
undeploy:
	docker stack rm oftee

.PHONY: up
up: bridge deploy add-iface flow-wait

.PHONY: down
down: undeploy del-bridge

.PHONY: wpa
wpa:
	docker exec -ti $(shell ./utils/cid oftee_host) wpa_supplicant -i eth2 -D wired -c /etc/wpa_supplicant/wpa_supplicant.conf -ddd

.PHONY: dhcp
dhcp:
	docker exec -ti $(shell ./utils/cid oftee_host) dhclient -4 -v -d -1 eth2

.PHONY: host.shell
host.shell:
	docker exec -ti $(shell ./utils/cid oftee_host) bash

.PHONY: radius.shell
radius.shell:
	docker exec -ti $(shell ./utils/cid oftee_radius) bash

.PHONY: aaa.shell
aaa.shell:
	docker exec -ti $(shell ./utils/cid oftee_aaa) bash

.PHONY: relay.shell
relay.shell:
	docker exec -ti $(shell ./utils/cid oftee_relay) ash

.PHONY: dhcp.shell
dhcp.shell:
	docker exec -ti $(shell ./utils/cid oftee_dhcpd) bash

.PHONY: oftee.logs
oftee.logs:
	docker service logs --raw -f oftee_oftee

.PHONY: aaa.logs
aaa.logs:
	docker service logs --raw -f oftee_aaa

.PHONY: radius.logs
radius.logs:
	docker service logs --raw -f oftee_radius

.PHONY: onos.logs
onos.logs:
	docker service logs -f oftee_onos

.PHONY: relay.logs
relay.logs:
	docker service logs -f oftee_relay

.PHONY: dhcp.logs
dhcp.logs:
	docker service logs -f oftee_dhcpd
