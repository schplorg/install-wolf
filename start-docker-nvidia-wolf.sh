#!/usr/bin/env bash
set -e

read -p "Use NVIDIA Container Toolkit method? (recommended) (y/n): " USE_TOOLKIT

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
    docker pull "$image"
    docker save "$image" -o "$tar"
  fi
  docker load -i "$tar"
done

docker ps -a --format "{{.Names}}" \
  | grep -iE '^wolf' \
  | xargs -r docker rm -f

if [[ "$USE_TOOLKIT" == "y" ]]; then

docker run -d \
  --name wolf \
  --restart unless-stopped \
  --network=host \
  -e NVIDIA_DRIVER_CAPABILITIES=all \
  -e NVIDIA_VISIBLE_DEVICES=all \
  --gpus=all \
  -v /etc/wolf:/etc/wolf:rw \
  -v /var/run/docker.sock:/var/run/docker.sock:rw \
  --device /dev/dri/ \
  --device /dev/uinput \
  --device /dev/uhid \
  -v /dev/:/dev/:rw \
  -v /run/udev:/run/udev:rw \
  --device-cgroup-rule "c 13:* rmw" \
  ghcr.io/games-on-whales/wolf:stable

else
  echo "Building NVIDIA driver container..."

  curl https://raw.githubusercontent.com/games-on-whales/gow/master/images/nvidia-driver/Dockerfile | \
    docker build -t gow/nvidia-driver:latest -f - \
    --build-arg NV_VERSION=$(cat /sys/module/nvidia/version) .

  docker volume rm nvidia-driver-vol 2>/dev/null || true

  docker create --rm \
    --mount source=nvidia-driver-vol,destination=/usr/nvidia \
    gow/nvidia-driver:latest sh

  docker run -d \
    --name wolf \
    --restart unless-stopped \
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
fi