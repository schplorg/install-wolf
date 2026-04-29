#!/usr/bin/env bash
set -euo pipefail

[ "$(id -u)" -ne 0 ] && echo "must be root" && exit 1

source .env

SUBNET="192.168.42.0/24"
GATEWAY="192.168.42.1"

ip link add "$DUMMY_ADAPTER" type dummy || true
ip addr add "$GATEWAY/24" dev "$DUMMY_ADAPTER" || true
ip link set "$DUMMY_ADAPTER" up

sysctl -w net.ipv4.ip_forward=1

iptables -t nat -A POSTROUTING -s "$SUBNET" -o "$LAN_ADAPTER" -j MASQUERADE
iptables -A FORWARD -i "$LAN_ADAPTER" -o "$DUMMY_ADAPTER" -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i "$DUMMY_ADAPTER" -o "$LAN_ADAPTER" -j ACCEPT
