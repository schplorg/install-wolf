#!/usr/bin/env bash
set -euo pipefail

[ "$(id -u)" -ne 0 ] && echo "must be root" && exit 1

source .env

$CONTAINER_TOOL network rm wolf_macvlan 2>/dev/null || true
