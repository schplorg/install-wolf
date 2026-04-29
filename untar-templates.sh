#!/usr/bin/env bash
set -euo pipefail

[ "$(id -u)" -ne 0 ] && echo "must be root" && exit 1

tar -xf ./templates/lutris-template.tar -C /etc/wolf/
tar -xf ./templates/user-template.tar -C /etc/wolf/profile-data/
