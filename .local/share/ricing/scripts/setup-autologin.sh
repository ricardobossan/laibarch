#!/bin/bash
# Setup autologin for TTY1
# Usage: ./setup-autologin.sh [username]

set -e

# Get username from argument or default to current user
USERNAME="${1:-$USER}"

echo "Setting up autologin for user: $USERNAME"

# Create systemd override directory
echo "Creating systemd override directory..."
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d

# Create autologin configuration
echo "Creating autologin configuration..."
sudo bash -c "cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf << \"EOF\"
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USERNAME --noclear %I \$TERM
EOF"

# Reload systemd
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo ""
echo "Autologin configuration complete!"
echo "User '$USERNAME' will automatically login on TTY1 after reboot."
echo ""
echo "Security note: Autologin bypasses password authentication."
echo "Only use on systems where physical security is assured."
