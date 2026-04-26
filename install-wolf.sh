#!/bin/bash

echo "🐺 Wolf preflight checks starting..."

USER_NAME="$(id -un)"
USER_ID="$(id -u)"
RUNTIME_DIR="/run/user/${USER_ID}"
PODMAN_SOCK="${RUNTIME_DIR}/podman/podman.sock"
UDEV_RULES="/etc/udev/rules.d/85-wolf.rules"

#######################################
# 1. Ensure required groups
#######################################
echo "🔍 Checking user groups..."

REQUIRED_GROUPS=("video" "input" "render")

for grp in "${REQUIRED_GROUPS[@]}"; do
    if id -nG "$USER_NAME" | grep -qw "$grp"; then
        echo "  ✔ user in group: $grp"
    else
        echo "  ❌ missing group: $grp"
        echo "     fixing..."
        sudo usermod -aG "$grp" "$USER_NAME"
        GROUP_FIX=1
    fi
done

if [[ "${GROUP_FIX:-0}" == "1" ]]; then
    echo "⚠️  Group changes applied. You MUST log out and back in."
fi

#######################################
# 2. Check device permissions
#######################################
echo "🔍 Checking device permissions..."

for dev in /dev/dri /dev/uinput /dev/uhid; do
    if [[ -e "$dev" ]]; then
        echo "  ✔ exists: $dev"
        ls -l "$dev" | sed 's/^/     /'
    else
        echo "  ⚠️ missing device: $dev"
    fi
done

#######################################
# 3. Ensure udev rules exist
#######################################
echo "🔍 Checking udev rules..."

if [[ ! -f "$UDEV_RULES" ]]; then
    echo "  ❌ missing udev rules, installing..."

    sudo curl -o "$$UDEV_RULES" https://raw.githubusercontent.com/games-on-whales/wolf/refs/heads/stable/85-wolf.rules
    sudo udevadm control --reload-rules
    sudo udevadm trigger

    echo "  ✔ udev rules installed and reloaded"
else
    echo "  ✔ udev rules present"
fi

#######################################
# 4. Enable rootless podman socket
#######################################
echo "🔍 Ensuring podman socket is running..."

systemctl --user enable --now podman.socket

sleep 1

if [[ -S "$PODMAN_SOCK" ]]; then
    echo "  ✔ podman socket found: $PODMAN_SOCK"
else
    echo "  ❌ podman socket missing"
    echo "     check: systemctl --user status podman.socket"
    exit 1
fi

podman ps -a --format "{{.Names}}" | grep -i '^wolf' | xargs -r podman rm -f || true
podman compose up -d