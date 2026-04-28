#!/usr/bin/env bash
set -e

[ "$(id -u)" -ne 0 ] && echo "must be root" && exit 1

echo "=== Wolf + NVIDIA Setup (Ubuntu 22.04) ==="

# -------- CONFIG PROMPTS --------
read -p "Install NVIDIA driver automatically? (y/n): " INSTALL_DRIVER
read -p "Use NVIDIA Container Toolkit method? (recommended) (y/n): " USE_TOOLKIT

# -------- SYSTEM UPDATE --------
echo "[1/8] Updating system..."
sudo apt update && sudo apt upgrade -y

# -------- NVIDIA DRIVER --------
if [[ "$INSTALL_DRIVER" == "y" ]]; then
  echo "[2/8] Installing NVIDIA driver..."
  sudo apt install -y ubuntu-drivers-common
  sudo ubuntu-drivers autoinstall
fi

# -------- DOCKER INSTALL --------
echo "[3/8] Installing Docker..."
sudo apt install -y ca-certificates curl gnupg lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo usermod -aG docker $USER

# -------- NVIDIA TOOLKIT --------
if [[ "$USE_TOOLKIT" == "y" ]]; then
  echo "[4/8] Installing NVIDIA Container Toolkit..."

  curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
    sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

  curl -s -L https://nvidia.github.io/libnvidia-container/stable/ubuntu22.04/libnvidia-container.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

  sudo apt update
  sudo apt install -y nvidia-container-toolkit

  sudo nvidia-ctk runtime configure --runtime=docker
  sudo systemctl restart docker
fi

# -------- VERIFY NVIDIA --------
echo "[5/8] Checking NVIDIA setup..."
if ! command -v nvidia-smi &> /dev/null; then
  echo "ERROR: nvidia-smi not found. Driver install likely failed."
  exit 1
fi

nvidia-smi || true

# -------- ENABLE DRM MODESET --------
echo "[6/8] Ensuring nvidia-drm modeset=1..."

if [[ -f /sys/module/nvidia_drm/parameters/modeset ]]; then
  MODESET=$(cat /sys/module/nvidia_drm/parameters/modeset)
else
  MODESET="N"
fi

if [[ "$MODESET" != "Y" ]]; then
  echo "Fixing GRUB config..."

  sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="nvidia-drm.modeset=1 /' /etc/default/grub
  sudo update-grub

  echo "Reboot required for DRM modeset fix."
  read -p "Reboot now? (y/n): " REBOOT
  if [[ "$REBOOT" == "y" ]]; then
    sudo reboot
    exit 0
  fi
fi

# -------- UDEV RULES --------
echo "[7/8] Setting up udev rules..."

sudo tee /etc/udev/rules.d/85-wolf-virtual-inputs.rules > /dev/null <<EOF
KERNEL=="uinput", SUBSYSTEM=="misc", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput", TAG+="uaccess"
KERNEL=="uhid", GROUP="input", MODE="0660", TAG+="uaccess"
EOF

sudo udevadm control --reload-rules && sudo udevadm trigger

# -------- NVIDIA DEVICE FIX --------
sudo nvidia-container-cli --load-kmods info || true
