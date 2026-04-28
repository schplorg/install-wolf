#!/bin/bash

set -euo pipefail

[ "$(id -u)" -ne 0 ] && echo "must be root" && exit 1

OVERLAY_BASE=/etc/wolf/.overlays

setup_overlays() {
  local template="$1"
  shift
  local targets=("$@")

  for target in "${targets[@]}"; do
    local name
    name=$(echo "$target" | tr '/' '_' | sed 's/^_//')

    local upper="$OVERLAY_BASE/$name/upper"
    local work="$OVERLAY_BASE/$name/work"

    if mountpoint -q "$target" 2>/dev/null; then
      umount "$target"
    fi

    rm -rf "${OVERLAY_BASE:?}/$name"
    mkdir -p "$upper" "$work" "$target"

    mount -t overlay overlay \
      -o lowerdir="$template",upperdir="$upper",workdir="$work" \
      "$target"
  done
}

setup_overlays /etc/wolf/lutris-template \
  /etc/wolf/lutris1 \
  /etc/wolf/lutris2 \
  /etc/wolf/lutris3 \
  /etc/wolf/lutris4

setup_overlays /etc/wolf/profile-data/user-template \
  /etc/wolf/profile-data/user1 \
  /etc/wolf/profile-data/user2 \
  /etc/wolf/profile-data/user3 \
  /etc/wolf/profile-data/user4