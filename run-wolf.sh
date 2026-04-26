#!/bin/bash
sudo podman rm -f $(sudo podman ps -a --format "{{.Names}}" | grep -iE '^wolf')
sudo podman run -d \
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
