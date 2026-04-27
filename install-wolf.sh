#!/bin/bash
set -euo pipefail

podman ps -a --format "{{.Names}}" | grep -i '^wolf' | xargs -r podman rm -f || true
podman --root /var/lib/wolf1 --runroot /run/wolf1 ps -a --format "{{.Names}}" | xargs -r podman --root /var/lib/wolf1 --runroot /run/wolf1 rm -f || true
podman --root /var/lib/wolf2 --runroot /run/wolf2 ps -a --format "{{.Names}}" | xargs -r podman --root /var/lib/wolf2 --runroot /run/wolf2 rm -f || true

mkdir -p /etc/wolf1 /etc/wolf2 /run/wolf1 /run/wolf2 /var/lib/wolf1 /var/lib/wolf2

cat > /etc/systemd/system/podman-wolf1.service <<EOF
[Unit]
Description=Podman socket for wolf1
After=network.target

[Service]
ExecStart=/usr/bin/podman system service --time=0 \
  --root /var/lib/wolf1 \
  --runroot /run/wolf1 \
  unix:///run/wolf1/podman.sock
Restart=always

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/podman-wolf2.service <<EOF
[Unit]
Description=Podman socket for wolf2
After=network.target

[Service]
ExecStart=/usr/bin/podman system service --time=0 \
  --root /var/lib/wolf2 \
  --runroot /run/wolf2 \
  unix:///run/wolf2/podman.sock
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now podman-wolf1 podman-wolf2

sleep 3

podman --root /var/lib/wolf1 --runroot /run/wolf1 network create \
  --driver macvlan \
  --opt parent=enp5s0 \
  --subnet 192.168.42.0/24 \
  --gateway 192.168.42.1 \
  wolf_macvlan

podman --root /var/lib/wolf2 --runroot /run/wolf2 network create \
  --driver macvlan \
  --opt parent=enp5s0 \
  --subnet 192.168.42.0/24 \
  --gateway 192.168.42.1 \
  wolf_macvlan

podman --root /var/lib/wolf1 --runroot /run/wolf1 run -d \
  --name wolf1 \
  --restart unless-stopped \
  --network wolf_macvlan \
  --ip 192.168.42.130 \
  -v /etc/wolf1:/etc/wolf:rw \
  -v /run/wolf1/podman.sock:/var/run/docker.sock:rw \
  -v /dev/:/dev/:rw \
  -v /run/udev:/run/udev:rw \
  --device /dev/dri \
  --device /dev/uinput \
  --device /dev/uhid \
  --device-cgroup-rule "c 13:* rmw" \
  ghcr.io/games-on-whales/wolf:stable

podman --root /var/lib/wolf2 --runroot /run/wolf2 run -d \
  --name wolf2 \
  --restart unless-stopped \
  --network wolf_macvlan \
  --ip 192.168.42.131 \
  -v /etc/wolf2:/etc/wolf:rw \
  -v /run/wolf2/podman.sock:/var/run/docker.sock:rw \
  -v /dev/:/dev/:rw \
  -v /run/udev:/run/udev:rw \
  --device /dev/dri \
  --device /dev/uinput \
  --device /dev/uhid \
  --device-cgroup-rule "c 13:* rmw" \
  ghcr.io/games-on-whales/wolf:stable