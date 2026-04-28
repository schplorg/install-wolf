#!/bin/bash

read -p "Use podman? (y/n): " USE_PODMAN

if [[ "$USE_TOOLKIT" == "y" ]]; then
  podman network create \
    --driver macvlan \
    --opt parent=enp5s0 \
    --subnet 192.168.42.0/24 \
    --gateway 192.168.42.1 \
    wolf_macvlan
else
  docker network create \
    --driver macvlan \
    --opt parent=enp5s0 \
    --subnet 192.168.42.0/24 \
    --gateway 192.168.42.1 \
    wolf_macvlan
fi
