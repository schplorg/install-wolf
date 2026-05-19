#!/usr/bin/env bash
set -euo pipefail
[ "$(id -u)" -ne 0 ] && echo "must be root" && exit 1

LUTRIS_DST="/etc/wolf/lutris-template"
PROFILE_DST="/etc/wolf/profile-data/user-template"
OUT_DIR="./templates"

mkdir -p "$OUT_DIR"

echo "==> Archiving lutris-template..."
tar -cvf "$OUT_DIR/lutris-template.tar" -C "$(dirname "$LUTRIS_DST")" "$(basename "$LUTRIS_DST")"

echo "==> Archiving user-template..."
tar -cvf "$OUT_DIR/user-template.tar" -C "$(dirname "$PROFILE_DST")" "$(basename "$PROFILE_DST")"

echo "==> Done. Archives written to $OUT_DIR/"