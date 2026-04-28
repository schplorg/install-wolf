#!/bin/bash

set -euo pipefail
source .env

$CONTAINER_TOOL rm -f $($CONTAINER_TOOL ps -a --format "{{.Names}}" | grep -iE '^wolf')
$CONTAINER_TOOL network rm wolf_macvlan || true