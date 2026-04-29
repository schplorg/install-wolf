#!/usr/bin/env bash
set -euo pipefail

[ "$(id -u)" -ne 0 ] && echo "must be root" && exit 1

ENV_FILE=".env"

echo "=== Wolf Setup ==="
echo ""

# ---- GPU type ----
echo "GPU type:"
echo "  1) NVIDIA"
echo "  2) AMD"
read -rp "Choice [1/2]: " GPU_CHOICE
case "$GPU_CHOICE" in
  1) GPU=nvidia ;;
  2) GPU=amd ;;
  *) echo "Invalid choice"; exit 1 ;;
esac

# ---- Container tool ----
echo "CONTAINER_TOOL type:"
echo "  1) docker"
echo "  2) podman"
read -rp "Choice [1/2]: " CONTAINER_TOOL_CHOICE
case "$CONTAINER_TOOL_CHOICE" in
  1) CONTAINER_TOOL=docker ;;
  2) CONTAINER_TOOL=podman ;;
  *) echo "Invalid choice"; exit 1 ;;
esac

# ---- Network adapter ----
echo ""
echo "Available network interfaces:"
ip -o link show | awk -F': ' '{print "  " $2}' | grep -v lo
echo ""
read -rp "Physical LAN adapter (e.g. eth0): " LAN_ADAPTER

# ---- Network mode ----
echo ""
echo "Network mode for game containers:"
echo "  1) Exposed host  - simple, no LAN discovery between games"
echo "  2) Macvlan LAN   - games appear on LAN, needed for LAN multiplayer"
read -rp "Choice [1/2]: " NET_CHOICE
case "$NET_CHOICE" in
  1) NETWORK_MODE=exposed ;;
  2) NETWORK_MODE=macvlan ;;
  *) echo "Invalid choice"; exit 1 ;;
esac

DUMMY_ADAPTER=""
MACVLAN_ADAPTER="$LAN_ADAPTER"
if [[ "$NETWORK_MODE" == "macvlan" ]]; then
  read -rp "Is this a cloud server without a real LAN? [y/N]: " IS_CLOUD
  if [[ "${IS_CLOUD,,}" == "y" ]]; then
    read -rp "Dummy adapter name [dummyeth-0]: " DUMMY_ADAPTER
    DUMMY_ADAPTER="${DUMMY_ADAPTER:-dummyeth-0}"
    MACVLAN_ADAPTER="$DUMMY_ADAPTER"
  fi
fi

# ---- Profile count ----
echo ""
read -rp "Number of user profiles to create [4]: " NUM_PROFILES
NUM_PROFILES="${NUM_PROFILES:-4}"
if ! [[ "$NUM_PROFILES" =~ ^[1-9][0-9]*$ ]]; then
  echo "Invalid number"; exit 1
fi

# ---- Write .env ----
cat > "$ENV_FILE" <<EOF
# GPU type: nvidia or amd
GPU=$GPU

# docker or podman
CONTAINER_TOOL=$CONTAINER_TOOL

# Physical network adapter on the host
LAN_ADAPTER=$LAN_ADAPTER

# Macvlan parent adapter (same as LAN_ADAPTER for real LAN, dummy adapter for cloud)
MACVLAN_ADAPTER=$MACVLAN_ADAPTER

# Dummy adapter name (cloud only, leave empty for real LAN)
DUMMY_ADAPTER=$DUMMY_ADAPTER

# Number of user profiles
NUM_PROFILES=$NUM_PROFILES

# Network mode: exposed or macvlan
NETWORK_MODE=$NETWORK_MODE
EOF

echo ""
echo "Written $ENV_FILE"
echo ""

# ---- Run install steps ----
if [[ "$GPU" == "nvidia" ]]; then
  read -rp "Run NVIDIA + Docker install now? [y/N]: " DO_INSTALL
  if [[ "${DO_INSTALL,,}" == "y" ]]; then
    bash install-docker-nvidia.sh
  fi
fi

if [[ "$NETWORK_MODE" == "macvlan" ]]; then
  if [[ -n "$DUMMY_ADAPTER" ]]; then
    bash create-dummy-eth.sh
  fi
  bash create-macvlan.sh
  bash apply-custom-lan.sh
else
  bash apply-custom-exposed-host.sh
fi

echo ""
echo "Done. Next steps:"
echo "  1. Start wolf:  bash start-wolf.sh"
echo "  2. Connect via Moonlight, pair and open Wolf UI"
echo "  3. Stop wolf:   bash stop-wolf.sh"
echo "  4. Set up profiles (see README.md)"
