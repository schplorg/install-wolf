#!/usr/bin/env bash
# Generates and appends user profile config to wolf's config.toml.
# Reads NUM_PROFILES and NETWORK_MODE from .env.
# Macvlan IPs start at 192.168.42.130.
set -euo pipefail

[ "$(id -u)" -ne 0 ] && echo "must be root" && exit 1

source .env

CONFIG="/etc/wolf/cfg/config.toml"
MARKER="# STARTCUSTOM"

# Remove any previous custom block
if grep -qF "$MARKER" "$CONFIG"; then
  sed -i "/^$MARKER$/,\$d" "$CONFIG"
fi

{
  echo ""
  echo "$MARKER"

  for i in $(seq 1 "$NUM_PROFILES"); do
    NUM=$i
    IP_SUFFIX=$((129 + i))   # user1 → .130, user2 → .131, ...

    if [[ "$NETWORK_MODE" == "macvlan" ]]; then
      NETWORK_JSON='"NetworkMode": "wolf_macvlan",'
      NETWORKING_CONFIG=$(cat <<NETEOF
  "NetworkingConfig": {
    "EndpointsConfig": {
      "wolf_macvlan": {
        "IPAMConfig": {
          "IPv4Address": "192.168.42.${IP_SUFFIX}"
        }
      }
    }
  }
NETEOF
)
    else
      NETWORK_JSON=""
      NETWORKING_CONFIG=""
    fi

    cat <<TOML

[[profiles]]
id = "user${NUM}"
name = "User${NUM}"

[[profiles.apps]]
icon_png_path = "https://games-on-whales.github.io/wildlife/apps/lutris/assets/icon.png"
start_virtual_compositor = true
title = "Lutris"

[profiles.apps.runner]
base_create_json = '''
{
  "HostConfig": {
    ${NETWORK_JSON}
    "IpcMode": "host",
    "CapAdd": ["SYS_ADMIN", "SYS_NICE", "SYS_PTRACE", "NET_RAW", "MKNOD", "NET_ADMIN"],
    "SecurityOpt": ["seccomp=unconfined", "apparmor=unconfined"],
    "Ulimits": [{"Name":"nofile", "Hard":524288, "Soft":524288}],
    "Privileged": false,
    "DeviceCgroupRules": ["c 13:* rmw", "c 244:* rmw"]
  }${NETWORKING_CONFIG:+,
$NETWORKING_CONFIG}
}
'''
devices = []
env = [
  "RUN_SWAY=1",
  "GOW_REQUIRED_DEVICES=/dev/input/event* /dev/dri/* /dev/nvidia* /var/lutris/"
]
image = "ghcr.io/games-on-whales/lutris:edge"
mounts = [
  "/etc/wolf/lutris${NUM}:/var/lutris/:rw",
  "/etc/wolf/lutris${NUM}/99-startup.sh:/opt/gow/startup.d/99-startup.sh"
]
name = "WolfLutris"
ports = []
type = "docker"
TOML
  done
} >> "$CONFIG"

echo "Wrote $NUM_PROFILES profile(s) to $CONFIG (mode: $NETWORK_MODE)"
