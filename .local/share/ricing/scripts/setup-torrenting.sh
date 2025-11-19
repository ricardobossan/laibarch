#!/bin/bash
# Setup Transmission with tremc for torrenting
# Usage: ./setup-torrenting.sh

set -e

USERNAME="$USER"

echo "Setting up Transmission torrenting for user: $USERNAME"
echo ""

# Install transmission-cli
echo "Installing transmission-cli..."
if ! pacman -Q transmission-cli &>/dev/null; then
    sudo pacman -S --noconfirm transmission-cli
    echo "transmission-cli installed."
else
    echo "transmission-cli already installed."
fi

# Install tremc from source
echo ""
echo "Installing tremc from source..."
TREMC_PATH="$HOME/.local/bin/tremc"

if [ ! -f "$TREMC_PATH" ]; then
    echo "Downloading tremc..."
    mkdir -p "$HOME/.local/bin"
    wget -q https://github.com/tremc/tremc/raw/refs/heads/master/tremc -O "$TREMC_PATH"

    # Make executable
    chmod +x "$TREMC_PATH"

    # Update shebang to use python3
    sed -i '1s|.*|#!/usr/bin/env python3|' "$TREMC_PATH"

    echo "tremc installed to $TREMC_PATH"
else
    echo "tremc already installed at $TREMC_PATH"
fi

# Install optional dependencies
echo ""
echo "Installing optional dependencies for tremc..."
sudo pacman -S --needed --noconfirm python-pyperclip xclip 2>/dev/null || echo "Note: Some optional dependencies may not be available"

# Configure transmission to run as current user
echo ""
echo "Configuring transmission service to run as $USERNAME..."
sudo mkdir -p /etc/systemd/system/transmission.service.d

sudo bash -c "cat > /etc/systemd/system/transmission.service.d/username.conf << EOF
[Service]
User=$USERNAME
EOF"

# Reload systemd
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

# Start and enable transmission service
echo "Starting transmission service..."
sudo systemctl enable transmission.service
sudo systemctl start transmission.service

# Wait for config file to be created
echo "Waiting for configuration file to be created..."
sleep 2

# Stop service to modify config
echo "Stopping service to modify configuration..."
sudo systemctl stop transmission.service

# Create downloads directory
DOWNLOAD_DIR="$HOME/Downloads/torrents"
mkdir -p "$DOWNLOAD_DIR"
mkdir -p "$DOWNLOAD_DIR/incomplete"

# Configure basic settings
CONFIG_FILE="$HOME/.config/transmission-daemon/settings.json"

if [ -f "$CONFIG_FILE" ]; then
    echo "Updating configuration..."

    # Backup original config
    cp "$CONFIG_FILE" "$CONFIG_FILE.backup"

    # Update download directories
    sed -i "s|\"download-dir\": \".*\"|\"download-dir\": \"$DOWNLOAD_DIR\"|" "$CONFIG_FILE"
    sed -i "s|\"incomplete-dir\": \".*\"|\"incomplete-dir\": \"$DOWNLOAD_DIR/incomplete\"|" "$CONFIG_FILE"
    sed -i 's|"incomplete-dir-enabled": false|"incomplete-dir-enabled": true|' "$CONFIG_FILE"

    # Enable web interface on localhost
    sed -i 's|"rpc-whitelist-enabled": true|"rpc-whitelist-enabled": false|' "$CONFIG_FILE"

    echo "Configuration updated. Backup saved to: $CONFIG_FILE.backup"
fi

# Restart service
echo "Starting transmission service..."
sudo systemctl start transmission.service

echo ""
echo "======================================"
echo "Transmission setup complete!"
echo "======================================"
echo ""
echo "Configuration:"
echo "  - Service runs as: $USERNAME"
echo "  - Download directory: $DOWNLOAD_DIR"
echo "  - Incomplete directory: $DOWNLOAD_DIR/incomplete"
echo "  - Config file: $CONFIG_FILE"
echo ""
echo "Usage:"
echo "  - TUI interface: tremc"
echo "  - Web interface: http://localhost:9091"
echo "  - CLI commands: transmission-remote"
echo ""
echo "Examples:"
echo "  transmission-remote -l                    # List torrents"
echo "  transmission-remote -a file.torrent       # Add torrent"
echo "  transmission-remote -a 'magnet:?xt=...'   # Add magnet link"
echo ""
echo "Service management:"
echo "  sudo systemctl status transmission        # Check status"
echo "  sudo systemctl stop transmission          # Stop service"
echo "  sudo systemctl start transmission         # Start service"
echo ""
echo "Note: Edit $CONFIG_FILE to customize settings"
echo "      (stop the service first: sudo systemctl stop transmission)"
