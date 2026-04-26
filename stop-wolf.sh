#!/bin/bash
sudo podman ps -a --format "{{.Names}}" | grep -i '^wolf' | xargs -r sudo podman rm -f
sudo podman container prune -f
sudo podman pod prune -f