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

podman compose up -d