#!/usr/bin/env bash
set -euo pipefail

[ "$(id -u)" -ne 0 ] && echo "must be root" && exit 1

mkdir -p /etc/wolf
modprobe overlay || { echo "failed to load overlay module"; exit 1; }

apt update
apt install -y podman