#!/usr/bin/env bash
set -euo pipefail

[ "$(id -u)" -ne 0 ] && echo "must be root" && exit 1

mkdir -p /etc/wolf

apt update
apt install -y podman
systemctl start podman.socket