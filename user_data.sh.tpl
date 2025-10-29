#!/bin/bash
set -euo pipefail

# --- System preparation ---
echo "[INFO] Updating system packages..."
yum update -y

# --- Create application user ---
USERNAME="${username}"
APP_DIR="${app_dir}"
PUB_KEY="${public_key}"

if ! id "$USERNAME" &>/dev/null; then
  echo "[INFO] Creating user: $USERNAME"
  useradd -m -s /bin/bash "$USERNAME"
fi
# --- Configure SSH access ---
echo "[INFO] Setting up SSH key for $USERNAME..."
mkdir -p /home/$USERNAME/.ssh
echo "$PUB_KEY" > /home/$USERNAME/.ssh/authorized_keys
chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
chmod 700 /home/$USERNAME/.ssh
chmod 600 /home/$USERNAME/.ssh/authorized_keys

# --- Create application directory ---
echo "[INFO] Creating application directory: $APP_DIR"
mkdir -p "$APP_DIR"
chown $USERNAME:$USERNAME "$APP_DIR"
chmod 775 "$APP_DIR"
# --- Enable firewall & security settings (optional hardening) ---
if command -v systemctl &>/dev/null; then
  echo "[INFO] Enabling basic security settings..."
  systemctl enable sshd
  systemctl start sshd
fi

# --- Install helpful tools ---
echo "[INFO] Installing common utilities..."
yum install -y git unzip curl vim

# --- Final message ---
echo "[INFO] Setup complete for user: $USERNAME"



