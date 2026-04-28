#!/usr/bin/env bash

set -euo pipefail

[ "$(id -u)" -ne 0 ] && echo "must be root" && exit 1

source .env

PARENT_IF=$DUMMY_ADAPTER
UPLINK_IF=$LAN_ADAPTER
SUBNET="192.168.42.0/24"
GATEWAY="192.168.42.1"

ip link add "$PARENT_IF" type dummy || true
ip addr add "$GATEWAY/24" dev "$PARENT_IF" || true
ip link set "$PARENT_IF" up

sysctl -w net.ipv4.ip_forward=1

iptables -t nat -A POSTROUTING -s "$SUBNET" -o "$UPLINK_IF" -j MASQUERADE
iptables -A FORWARD -i "$UPLINK_IF" -o "$PARENT_IF" -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i "$PARENT_IF" -o "$UPLINK_IF" -j ACCEPT