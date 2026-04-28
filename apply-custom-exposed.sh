#!/usr/bin/env bash

[ "$(id -u)" -ne 0 ] && echo "must be root" && exit 1

CONFIG="/etc/wolf/cfg/config.toml"
CUSTOM="custom-exposed-host.toml"
MARKER="# STARTCUSTOM"

if grep -qF "$MARKER" "$CONFIG"; then
  # marker exists → replace everything after it
  sed -i "/^$MARKER$/q" "$CONFIG"
  cat "$CUSTOM" >> "$CONFIG"
else
  # marker missing → append
  {
    echo ""
    echo "$MARKER"
    cat "$CUSTOM"
  } >> "$CONFIG"
fi