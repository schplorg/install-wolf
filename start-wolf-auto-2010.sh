#!/usr/bin/env bash
set -euo pipefail

[ "$(id -u)" -ne 0 ] && echo "must be root" && exit 1

bash start-wolf-auto.sh

# AVP 2010 workaround
timedatectl set-ntp false
date -s "2010-12-19 12:00:00"