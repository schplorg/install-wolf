#!/bin/bash
podman ps -a --format "{{.Names}}" | grep -i '^wolf' | xargs -r podman rm -f
podman container prune -f
podman pod prune -f