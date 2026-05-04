#!/usr/bin/env bash
set -euo pipefail

[ "$(id -u)" -ne 0 ] && echo "must be root" && exit 1

source .env

$CONTAINER_TOOL rm -f $($CONTAINER_TOOL ps -a --format "{{.Names}}" | grep -iE '^wolf') || true

# revert AVP 2010 workaround
timedatectl set-ntp true