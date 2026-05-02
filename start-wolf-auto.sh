#!/bin/bash

bash stop-wolf.sh
bash rm-overlays.sh
bash overlay-profiles.sh
bash generate-profiles.sh

if [[ "$NETWORK_MODE" == "macvlan" ]]; then
  if [[ -n "$DUMMY_ADAPTER" ]]; then
    bash rm-dummy-eth.sh
    bash create-dummy-eth.sh
  fi
  bash create-macvlan.sh
fi

bash start-wolf.sh