#!/usr/bin/env bash
set -euo pipefail
[ "$(id -u)" -ne 0 ] && echo "must be root" && exit 1

LUTRIS_SRC="/etc/wolf/lutris1"
PROFILE_SRC="/etc/wolf/profile-data/user1"
LUTRIS_DST="/etc/wolf/lutris-template"
PROFILE_DST="/etc/wolf/profile-data/user-template"
LUTRIS_TMP="/tmp/lutris-template.$$"
PROFILE_TMP="/tmp/user-template.$$"

echo "==> Copying sources to tmp..."
rsync -avP "$LUTRIS_SRC/" "$LUTRIS_TMP/"
rsync -avP "$PROFILE_SRC/" "$PROFILE_TMP/"

echo "==> Destroying overlayfs for user1 and lutris1..."
./rm-overlays.sh

echo "==> Replacing templates..."
rm -rf "$LUTRIS_DST"
mv "$LUTRIS_TMP" "$LUTRIS_DST"

rm -rf "$PROFILE_DST"
mv "$PROFILE_TMP" "$PROFILE_DST"

echo "==> Recreating overlays from new templates..."
./overlay-profiles.sh

echo "==> Done."