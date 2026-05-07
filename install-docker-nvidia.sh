#!/usr/bin/env bash
set -euo pipefail

[ "$(id -u)" -ne 0 ] && echo "must be root" && exit 1

mkdir -p /etc/wolf

echo "=== NVIDIA + Docker Install ==="

read -rp "Install NVIDIA driver automatically? [y/N]: " INSTALL_DRIVER
read -rp "Install NVIDIA Container Toolkit? (recommended) [y/N]: " USE_TOOLKIT

apt update
apt upgrade -y

if [[ "${INSTALL_DRIVER,,}" == "y" ]]; then
  apt update

  if [[ -n "$NVIDIA_DRIVER_VERSION" ]]; then
    apt install nvidia-driver-$NVIDIA_DRIVER_VERSION
  else
    # Find the highest nvidia-driver-NNN package available
    LATEST=$(apt-cache search nvidia-driver | \
      grep -oP 'nvidia-driver-\K[0-9]+' | \
      sort -n | tail -1)
    apt install -y "nvidia-driver-$LATEST"
  fi
fi

apt install -y ca-certificates curl gnupg lsb-release
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
usermod -aG docker "$SUDO_USER"

if [[ "${USE_TOOLKIT,,}" == "y" ]]; then
  curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
    gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

  curl -sL https://nvidia.github.io/libnvidia-container/stable/ubuntu22.04/libnvidia-container.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

  apt update
  apt install -y nvidia-container-toolkit
  nvidia-ctk runtime configure --runtime=docker
  systemctl restart docker
fi

command -v nvidia-smi &>/dev/null || { echo "ERROR: nvidia-smi not found"; exit 1; }
nvidia-smi || true

MODESET=$(cat /sys/module/nvidia_drm/parameters/modeset 2>/dev/null || echo N)
if [[ "$MODESET" != "Y" ]]; then
  sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="nvidia-drm.modeset=1 /' /etc/default/grub
  update-grub
  read -rp "Reboot required for DRM modeset. Reboot now? [y/N]: " REBOOT
  [[ "${REBOOT,,}" == "y" ]] && reboot
fi

tee /etc/udev/rules.d/85-wolf-virtual-inputs.rules > /dev/null <<EOF
KERNEL=="uinput", SUBSYSTEM=="misc", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput", TAG+="uaccess"
KERNEL=="uhid", GROUP="input", MODE="0660", TAG+="uaccess"
EOF

udevadm control --reload-rules && udevadm trigger

if [[ "${USE_TOOLKIT,,}" == "y" ]]; then
  nvidia-container-cli --load-kmods info || true
fi

echo "NVIDIA + Docker setup complete."
