#!/bin/bash
instances=(
  "peer_one:10.13.13.2"
)
sudo podman ps -a --format "{{.Names}}" | grep -i '^wolf' | xargs -r sudo podman rm -f
for entry in "${instances[@]}"; do
  INSTANCE="${entry%%:*}"
  BIND_IP="${entry##*:}"
  sudo mkdir -p "/etc/wolf-${INSTANCE}"
  echo "Starting wolf-${INSTANCE} on ${BIND_IP}..."
  sudo INSTANCE="${INSTANCE}" BIND_IP="${BIND_IP}" podman compose \
    --project-name "wolf-${INSTANCE}" \
    up -d
done