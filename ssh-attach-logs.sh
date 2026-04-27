#!/bin/bash
set -euo pipefail

ssh-keygen -f ~/.ssh/known_hosts -R "$2"
ssh "$1@$2" -p 22 \
  "podman --root /var/lib/wolf${3} --runroot /run/wolf${3} logs -f wolf"