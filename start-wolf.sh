#!/usr/bin/env bash
set -euo pipefail

[ "$(id -u)" -ne 0 ] && echo "must be root" && exit 1

source .env

mkdir -p images

IMAGES=(
  ghcr.io/games-on-whales/wolf:stable
  ghcr.io/games-on-whales/pulseaudio:master
  ghcr.io/games-on-whales/wolf-ui:main
  ghcr.io/games-on-whales/lutris:edge
)

for image in "${IMAGES[@]}"; do
  tar="images/$(echo "$image" | tr '/: ' '---').tar"

  if $CONTAINER_TOOL image inspect "$image" &>/dev/null; then
    echo "Image already loaded, skipping: $image"
    continue
  fi

  if [[ ! -f "$tar" ]]; then
    $CONTAINER_TOOL pull "$image"
    $CONTAINER_TOOL save "$image" -o "$tar"
  fi
  $CONTAINER_TOOL load -i "$tar"
done

$CONTAINER_TOOL ps -a --format "{{.Names}}" \
  | grep -iE '^wolf' \
  | xargs -r $CONTAINER_TOOL rm -f || true

if [[ "$GPU" == "nvidia" ]]; then
  NV_TAR="images/gow---nvidia-driver---latest.tar"
  if [[ -f "$NV_TAR" ]]; then
    docker load -i "$NV_TAR"
  else
    curl https://raw.githubusercontent.com/games-on-whales/gow/master/images/nvidia-driver/Dockerfile | \
      docker build -t gow/nvidia-driver:latest -f - \
      --build-arg NV_VERSION="$(cat /sys/module/nvidia/version)" .
    docker save gow/nvidia-driver:latest -o "$NV_TAR"
  fi

  docker volume rm nvidia-driver-vol 2>/dev/null || true
  docker create --rm \
    --mount source=nvidia-driver-vol,destination=/usr/nvidia \
    gow/nvidia-driver:latest sh

  docker run -d \
    --name wolf \
    --network=host \
    -e NVIDIA_DRIVER_VOLUME_NAME=nvidia-driver-vol \
    -v nvidia-driver-vol:/usr/nvidia:rw \
    -v /etc/wolf:/etc/wolf:rw \
    -v /var/run/docker.sock:/var/run/docker.sock:rw \
    --device /dev/nvidia-uvm \
    --device /dev/nvidia-uvm-tools \
    --device /dev/dri/ \
    --device /dev/nvidia-caps/nvidia-cap1 \
    --device /dev/nvidia-caps/nvidia-cap2 \
    --device /dev/nvidiactl \
    --device /dev/nvidia0 \
    --device /dev/nvidia-modeset \
    --device /dev/uinput \
    --device /dev/uhid \
    -v /dev/:/dev/:rw \
    -v /run/udev:/run/udev:rw \
    --device-cgroup-rule "c 13:* rmw" \
    ghcr.io/games-on-whales/wolf:stable

else
  # AMD via podman or docker
  if [[ "$CONTAINER_TOOL" == "docker" ]]; then
    docker run -d \
      --name wolf \
      --network=host \
      -v /etc/wolf:/etc/wolf:rw \
      -v /run/docker/docker.sock:/var/run/docker.sock:rw \
      --device /dev/dri/ \
      --device /dev/uinput \
      --device /dev/uhid \
      -v /dev/:/dev/:rw \
      -v /run/udev:/run/udev:rw \
      --device-cgroup-rule "c 13:* rmw" \
      ghcr.io/games-on-whales/wolf:stable
  else
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
  fi
fi
