#!/bin/bash
set -euo pipefail

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
done

for i in 1 2 3 4; do
  podman --root /var/lib/wolf${i} --runroot /run/wolf${i} rm -af || true

  mkdir -p /etc/wolf${i} /run/wolf${i} /var/lib/wolf${i}

  for image in "${IMAGES[@]}"; do
    tar="images/$(echo $image | tr '/: ' '---').tar"
    podman --root /var/lib/wolf${i} --runroot /run/wolf${i} load -i "$tar"
  done

  cat > /etc/systemd/system/podman-wolf${i}.service <<EOF
[Unit]
Description=Podman socket for wolf${i}
After=network.target

[Service]
ExecStart=/usr/bin/podman system service --time=0 \
  --root /var/lib/wolf${i} \
  --runroot /run/wolf${i} \
  unix:///run/wolf${i}/podman.sock
Restart=always

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable --now podman-wolf${i} || true

  sleep 3

  podman --root /var/lib/wolf${i} --runroot /run/wolf${i} network create \
    --driver macvlan \
    --opt parent=enp5s0 \
    --subnet 192.168.42.0/24 \
    --gateway 192.168.42.1 \
    wolf_macvlan || true

  podman --root /var/lib/wolf${i} --runroot /run/wolf${i} run -d \
    --name wolf --restart unless-stopped \
    --network wolf_macvlan --ip 192.168.42.$((129 + i)) \
    -v /etc/wolf${i}:/etc/wolf:rw \
    -v /run/wolf${i}/podman.sock:/var/run/docker.sock:rw \
    -v /dev/:/dev/:rw -v /run/udev:/run/udev:rw \
    --device /dev/dri --device /dev/uinput --device /dev/uhid \
    --device-cgroup-rule "c 13:* rmw" \
    ghcr.io/games-on-whales/wolf:stable
done