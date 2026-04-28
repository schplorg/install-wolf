#!/bin/bash

[ "$(id -u)" -ne 0 ] && echo "must be root" && exit 1

set -euo pipefail
source .env

$CONTAINER_TOOL rm -f $($CONTAINER_TOOL ps -a --format "{{.Names}}" | grep -iE '^wolf')
$CONTAINER_TOOL network rm wolf_macvlan || true