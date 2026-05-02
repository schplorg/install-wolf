#!/usr/bin/env bash
set -euo pipefail
[ "$(id -u)" -ne 0 ] && echo "must be root" && exit 1

source .env

OVERLAY_BASE=/etc/wolf/.overlays

[ $# -ne 2 ] && echo "Usage: $0 <overlay-target> <template>" && exit 1

TARGET="$1"
TEMPLATE="$2"
NAME=$(echo "$TARGET" | tr '/' '_' | sed 's/^_//')
UPPER="$OVERLAY_BASE/$NAME/upper"

[ ! -d "$UPPER" ] && echo "Error: no upper dir found at $UPPER" && exit 1
[ ! -d "$TEMPLATE" ] && echo "Error: template dir not found: $TEMPLATE" && exit 1

read -rp "Overwrite $TEMPLATE with $TARGET state? [y/N] " confirm
[[ "$confirm" != "y" && "$confirm" != "Y" ]] && exit 0

while IFS= read -r -d '' whiteout; do
  dir=$(dirname "$whiteout")
  base=$(basename "$whiteout" | sed 's/^\.wh\.//')
  rel_dir="${dir#"$UPPER"}"
  target_path=$(echo "$TEMPLATE/${rel_dir}/${base}" | sed 's|//|/|g')
  [ -e "$target_path" ] || [ -L "$target_path" ] && rm -rf "$target_path"
done < <(find "$UPPER" -name '.wh.*' ! -name '.wh..wh..opq' -print0)

while IFS= read -r -d '' opaque; do
  rel_dir="${$(dirname "$opaque")#"$UPPER"}"
  target_path=$(echo "$TEMPLATE/${rel_dir}" | sed 's|//|/|g')
  [ -d "$target_path" ] && rm -rf "$target_path" && mkdir -p "$target_path"
done < <(find "$UPPER" -name '.wh..wh..opq' -print0)

rsync -a --exclude='.wh.*' "$UPPER/" "$TEMPLATE/"