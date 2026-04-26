#!/bin/bash
sudo podman ps -a --format "{{.Names}}" | grep -i '^wolf' | xargs -r podman rm -f || true
sudo podman compose up -d