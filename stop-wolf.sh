#!/bin/bash
for i in 1 2 3 4; do
  podman --root /var/lib/wolf${i} --runroot /run/wolf${i} \
  ps -a --format "{{.Names}}" \
  | xargs -r podman --root /var/lib/wolf${i} --runroot /run/wolf${i} \
  rm -f || true
end