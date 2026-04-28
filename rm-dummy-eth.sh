#!/usr/bin/env bash

set -euo pipefail

[ "$(id -u)" -ne 0 ] && echo "must be root" && exit 1

source .env

PARENT_IF=$DUMMY_ADAPTER
UPLINK_IF=$LAN_ADAPTER
SUBNET="192.168.42.0/24"

iptables -t nat -D POSTROUTING -s "$SUBNET" -o "$UPLINK_IF" -j MASQUERADE || true
iptables -D FORWARD -i "$UPLINK_IF" -o "$PARENT_IF" -m state --state RELATED,ESTABLISHED -j ACCEPT || true
iptables -D FORWARD -i "$PARENT_IF" -o "$UPLINK_IF" -j ACCEPT || true

ip link delete "$PARENT_IF" || true