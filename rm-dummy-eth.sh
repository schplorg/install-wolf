#!/usr/bin/env bash
set -euo pipefail

[ "$(id -u)" -ne 0 ] && echo "must be root" && exit 1

source .env

DUMMY_OFFLINE="${DUMMY_OFFLINE:-false}"

SUBNET="192.168.42.0/24"

if [ "$DUMMY_OFFLINE" != "true" ]; then
    iptables -t nat -D POSTROUTING -s "$SUBNET" -o "$LAN_ADAPTER" -j MASQUERADE || true
    iptables -D FORWARD -i "$LAN_ADAPTER" -o "$HOST_IF" -m state --state RELATED,ESTABLISHED -j ACCEPT || true
    iptables -D FORWARD -i "$HOST_IF" -o "$LAN_ADAPTER" -j ACCEPT || true
else
    iptables -D FORWARD -i "$HOST_IF" -o "$LAN_ADAPTER" -j DROP || true
    iptables -D FORWARD -i "$LAN_ADAPTER" -o "$HOST_IF" -j DROP || true
fi

ip link delete "$HOST_IF" || true
ip link delete "$DUMMY_ADAPTER" || true