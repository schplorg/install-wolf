#!/bin/bash
for i in 1 2 3 4; do
  podman --root /var/lib/wolf${i} --runroot /run/wolf${i} \
  ps -a --format "{{.Names}}" \
  | xargs -r podman --root /var/lib/wolf${i} --runroot /run/wolf${i} \
  rm -f || true
  systemctl stop --now podman-wolf${i} || true
  systemctl disable --now podman-wolf${i} || true
  rm -rf /etc/systemd/system/podman-wolf${i}.service
  systemctl daemon-reload
  rm -rf /run/wolf${i} /var/lib/wolf${i}
done