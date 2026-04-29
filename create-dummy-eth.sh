#!/usr/bin/env bash
set -euo pipefail

[ "$(id -u)" -ne 0 ] && echo "must be root" && exit 1

source .env

SUBNET="192.168.42.0/24"
GATEWAY="192.168.42.1"

ip link add "$DUMMY_ADAPTER" type dummy || true
ip link set "$DUMMY_ADAPTER" up

ip link add "$HOST_IF" link "$DUMMY_ADAPTER" type macvlan mode bridge || true
ip addr add "$GATEWAY/24" dev "$HOST_IF" || true
ip link set "$HOST_IF" up

sysctl -w net.ipv4.ip_forward=1

iptables -t nat -A POSTROUTING -s "$SUBNET" -o "$LAN_ADAPTER" -j MASQUERADE
iptables -A FORWARD -i "$LAN_ADAPTER" -o "$HOST_IF" -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i "$HOST_IF" -o "$LAN_ADAPTER" -j ACCEPT