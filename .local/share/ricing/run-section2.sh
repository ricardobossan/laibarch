#!/bin/bash
# Master script for Section 2: Complete Fresh Install
# Run this as ROOT from a pendrive on a fresh Arch installation
# Prerequisites: Basic system installed, booted, but user/internet/pacman not configured

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run as root"
    echo "Usage: sudo bash run-section2.sh"
    exit 1
fi

echo "========================================"
echo "  Section 2: Complete Fresh Install"
echo "========================================"
echo ""

# Step 1: Configure root password
echo "Step 1: Configure root password"
echo "--------------------------------"
passwd root
echo ""

# Step 2: Configure sudo for wheel group
echo "Step 2: Configuring sudo for wheel group..."
echo "--------------------------------"
# Uncomment the wheel group line in sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
echo "Wheel group configured for sudo access"
echo ""

# Step 3: Create user
echo "Step 3: Create new user"
echo "--------------------------------"
read -p "Enter username for new user: " NEW_USER

if [ -z "$NEW_USER" ]; then
    echo "ERROR: Username cannot be empty"
    exit 1
fi

# Create user with home directory, add to wheel group, set bash as shell
useradd -mG wheel -s /bin/bash "$NEW_USER"

# Set password for new user
echo "Set password for user $NEW_USER:"
passwd "$NEW_USER"
echo ""

# Step 3.5: Copy repository to user's home
echo "Step 3.5: Copying repository to user home..."
echo "--------------------------------"
# Get the parent directory of SCRIPT_DIR (the repo root)
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
USER_HOME="/home/$NEW_USER"

# Copy the entire repo structure to user's home, preserving structure
echo "Copying repository files from $REPO_ROOT to $USER_HOME..."
# Use rsync if available, otherwise cp
if command -v rsync &> /dev/null; then
    rsync -av --exclude='.git' "$REPO_ROOT/" "$USER_HOME/"
else
    cp -r "$REPO_ROOT/." "$USER_HOME/"
fi

# Fix ownership
chown -R "$NEW_USER:$NEW_USER" "$USER_HOME"
echo "Repository copied successfully!"
echo ""

# Step 4: Configure pacman
echo "Step 4: Configuring pacman..."
echo "--------------------------------"
bash "$SCRIPT_DIR/configure-pacman.sh"
echo ""

# Step 5: Get WiFi credentials BEFORE switching network backend
echo "Step 5: Network configuration"
echo "--------------------------------"
echo "Current network connections:"
nmcli connection show --active

read -p "Enter WiFi SSID (network name): " WIFI_SSID
read -sp "Enter WiFi password: " WIFI_PASSWORD
echo ""

if [ -z "$WIFI_SSID" ] || [ -z "$WIFI_PASSWORD" ]; then
    echo "WARNING: WiFi credentials not provided. You'll need to reconnect manually."
    read -p "Continue anyway? (y/n): " CONTINUE
    if [ "$CONTINUE" != "y" ]; then
        exit 1
    fi
fi
echo ""

# Step 6: Run Section 1 scripts as the new user (needs network)
echo "Step 6: Running Section 1 installation (as user $NEW_USER)..."
echo "--------------------------------"
# Export variables for the user context
export HOME="/home/$NEW_USER"
export USER="$NEW_USER"

# Run Section 1 as the new user
sudo -u "$NEW_USER" bash "$SCRIPT_DIR/run-section1.sh"
echo ""

# Step 7: Configure network backend (this will disconnect)
echo "Step 7: Switching to iwd network backend..."
echo "--------------------------------"
echo "WARNING: This will temporarily disconnect the network"
bash "$SCRIPT_DIR/configure-network.sh"
echo ""

# Step 8: Reconnect to WiFi if credentials were provided
if [ -n "$WIFI_SSID" ] && [ -n "$WIFI_PASSWORD" ]; then
    echo "Step 8: Reconnecting to WiFi..."
    echo "--------------------------------"
    sleep 3  # Give NetworkManager time to restart

    # Try to connect using nmcli
    if nmcli device wifi connect "$WIFI_SSID" password "$WIFI_PASSWORD"; then
        echo "Successfully reconnected to $WIFI_SSID"
    else
        echo "WARNING: Automatic reconnection failed."
        echo "Please reconnect manually using: nmcli device wifi connect \"$WIFI_SSID\" password \"YOUR_PASSWORD\""
    fi
else
    echo "Step 8: Skipped (no WiFi credentials provided)"
    echo "Please connect manually using: nmcli device wifi connect \"SSID\" password \"PASSWORD\""
fi
echo ""

echo "========================================"
echo "  Section 2 Complete!"
echo "========================================"
echo ""
echo "Installation finished! You can now:"
echo "  1. Reboot the system: reboot"
echo "  2. Login as user: $NEW_USER"
echo "  3. DWL should start automatically"
echo ""
