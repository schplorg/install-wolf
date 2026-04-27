#!/bin/bash
podman rm -f $(podman ps -a --format "{{.Names}}" | grep -iE '^wolf')
podman network rm wolf_macvlan || true