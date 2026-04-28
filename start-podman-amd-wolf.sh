#!/bin/bash

mkdir -p images

IMAGES=(
  ghcr.io/games-on-whales/wolf:stable
  ghcr.io/games-on-whales/pulseaudio:master
  ghcr.io/games-on-whales/wolf-ui:main
  ghcr.io/games-on-whales/lutris:edge
)

for image in "${IMAGES[@]}"; do
  tar="images/$(echo $image | tr '/: ' '---').tar"
  if [[ ! -f "$tar" ]]; then
    podman pull "$image"
    podman save "$image" -o "$tar"
  fi
  podman load -i "$tar"
done

podman network create \
  --driver macvlan \
  --opt parent=enp5s0 \
  --subnet 192.168.42.0/24 \
  --gateway 192.168.42.1 \
  wolf_macvlan

podman ps -a --format "{{.Names}}" \
  | grep -iE '^wolf' \
  | xargs -r podman rm -f
podman run -d \
    --name wolf \
    --network=host \
    -v /etc/wolf:/etc/wolf:rw \
    -v /run/podman/podman.sock:/var/run/docker.sock:rw \
    --device /dev/dri/ \
    --device /dev/uinput \
    --device /dev/uhid \
    -v /dev/:/dev/:rw \
    -v /run/udev:/run/udev:rw \
    --device-cgroup-rule "c 13:* rmw" \
    ghcr.io/games-on-whales/wolf:stable
