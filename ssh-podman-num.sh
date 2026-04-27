#!/bin/bash
set -euo pipefail

set -a
[ -f .env ] && source .env
set +a

NUM="$1"
shift

ssh-keygen -f ~/.ssh/known_hosts -R "$SSH_HOST"
ssh -tt "$SSH_USER@$SSH_HOST" -p 22 \
  "/bin/bash -c 'sudo podman --root /var/lib/wolf$NUM --runroot /run/wolf$NUM $*'"