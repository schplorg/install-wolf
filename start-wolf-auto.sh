#!/usr/bin/env bash
set -euo pipefail

[ "$(id -u)" -ne 0 ] && echo "must be root" && exit 1

source .env

bash stop-wolf.sh
bash rm-overlays.sh
bash overlay-profiles.sh
bash generate-profiles.sh

if [[ "$NETWORK_MODE" == "macvlan" ]]; then
  bash rm-macvlan.sh
  if [[ -n "$DUMMY_ADAPTER" ]]; then
    bash rm-dummy-eth.sh
    bash create-dummy-eth.sh
  fi
  bash create-macvlan.sh
fi

bash start-wolf.sh