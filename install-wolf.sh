#!/bin/bash
set -euo pipefail

for i in 1 2 3 4; do
  podman --root /var/lib/wolf${i} --runroot /run/wolf${i} \
  ps -a --format "{{.Names}}" \
  | xargs -r podman --root /var/lib/wolf${i} --runroot /run/wolf${i} \
  rm -f || true

  mkdir -p /etc/wolf${i} /run/wolf${i} /var/lib/wolf${i}

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