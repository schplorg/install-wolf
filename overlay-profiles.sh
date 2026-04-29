#!/usr/bin/env bash
set -euo pipefail

[ "$(id -u)" -ne 0 ] && echo "must be root" && exit 1

source .env

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

    mountpoint -q "$target" 2>/dev/null && umount "$target"
    rm -rf "${OVERLAY_BASE:?}/$name"
    mkdir -p "$upper" "$work" "$target"

    mount -t overlay overlay \
      -o lowerdir="$template",upperdir="$upper",workdir="$work" \
      "$target"
  done
}

LUTRIS_TARGETS=()
PROFILE_TARGETS=()
for i in $(seq 1 "$NUM_PROFILES"); do
  LUTRIS_TARGETS+=("/etc/wolf/lutris${i}")
  PROFILE_TARGETS+=("/etc/wolf/profile-data/user${i}")
done

setup_overlays /etc/wolf/lutris-template "${LUTRIS_TARGETS[@]}"
setup_overlays /etc/wolf/profile-data/user-template "${PROFILE_TARGETS[@]}"

echo "Overlays set up for $NUM_PROFILES profile(s)."
