#!/bin/bash

set -euo pipefail

OVERLAY_BASE=/etc/wolf/.overlays

targets=(
  /etc/wolf/lutris1
  /etc/wolf/lutris2
  /etc/wolf/lutris3
  /etc/wolf/lutris4
  /etc/wolf/profile-data/user1
  /etc/wolf/profile-data/user2
  /etc/wolf/profile-data/user3
  /etc/wolf/profile-data/user4
)

for target in "${targets[@]}"; do
  if mountpoint -q "$target" 2>/dev/null; then
    umount "$target"
  fi
  rm -rf "$target"
done

rm -rf "$OVERLAY_BASE"