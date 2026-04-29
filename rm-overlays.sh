#!/usr/bin/env bash
set -euo pipefail

[ "$(id -u)" -ne 0 ] && echo "must be root" && exit 1

source .env

OVERLAY_BASE=/etc/wolf/.overlays

for i in $(seq 1 "$NUM_PROFILES"); do
  for target in "/etc/wolf/lutris${i}" "/etc/wolf/profile-data/user${i}"; do
    mountpoint -q "$target" 2>/dev/null && umount "$target"
    rm -rf "$target"
  done
done

rm -rf "$OVERLAY_BASE"
