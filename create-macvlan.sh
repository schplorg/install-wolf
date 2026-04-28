#!/bin/bash

set -euo pipefail

[ "$(id -u)" -ne 0 ] && echo "must be root" && exit 1

source .env

$CONTAINER_TOOL network create \
  --driver macvlan \
  --opt parent=enp5s0 \
  --subnet 192.168.42.0/24 \
  --gateway 192.168.42.1 \
  wolf_macvlan