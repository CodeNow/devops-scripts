#!/bin/bash
# This should be run after docker is started, order matters here

# drop pings
iptables -I INPUT -p icmp --icmp-type echo-request -m state --state ESTABLISHED -j DROP

# prevent containers from talking to host
iptables -I INPUT -s {{ docker_network }} -d 10.0.0.0/8 -m state --state NEW -j DROP

# drop all new traffic from container ip to runnable infra
iptables -I FORWARD -s {{ docker_network }} -d 10.0.0.0/8 -m state --state NEW -j DROP
# log container traffic for PSAD
iptables -I FORWARD -s {{ docker_network }} -j LOG
# drop all local container to container traffic
iptables -I FORWARD -s {{ docker_network }} -d {{ docker_network }} -j DROP
# allow aws DNS server queries (must be first)
iptables -I FORWARD -s {{ docker_network }} -d {{ ansible_dns.nameservers[0] }} -j ACCEPT

# drop all new traffic from container to runnable infra
iptables -I OUTPUT -s {{ docker_network }} -d 10.0.0.0/8 -m state --state NEW -j DROP
