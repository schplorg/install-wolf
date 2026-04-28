#!/usr/bin/env bash

CONFIG="/etc/wolf/cfg/config.toml"
CUSTOM="custom-exposed-host.toml"
MARKER="# STARTCUSTOM"

read -p "Use macvlan local network config? (y/n): " USE_LOCAL
if [[ "$USE_TOOLKIT" == "y" ]]; then
  CUSTOM="custom-lan-host.toml"
fi

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