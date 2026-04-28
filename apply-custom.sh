#!/usr/bin/env bash

CONFIG="/etc/wolf/cfg/config.toml"
CUSTOM="$1"
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