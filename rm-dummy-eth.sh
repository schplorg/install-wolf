#!/usr/bin/env bash
set -euo pipefail

[ "$(id -u)" -ne 0 ] && echo "must be root" && exit 1

source .env

SUBNET="192.168.42.0/24"

iptables -t nat -D POSTROUTING -s "$SUBNET" -o "$LAN_ADAPTER" -j MASQUERADE || true
iptables -D FORWARD -i "$LAN_ADAPTER" -o "$DUMMY_ADAPTER" -m state --state RELATED,ESTABLISHED -j ACCEPT || true
iptables -D FORWARD -i "$DUMMY_ADAPTER" -o "$LAN_ADAPTER" -j ACCEPT || true
ip link delete "$DUMMY_ADAPTER" || true
