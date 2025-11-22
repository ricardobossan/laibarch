#!/bin/bash
# Simple bootstrap for fresh Arch install
set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Install everything from programs.txt with pacman FIRST (needed for building dwl/slstatus)
echo "Installing packages from programs.txt..."
# Clean the file: remove empty lines and whitespace, then install all at once
grep -v '^[[:space:]]*$' "$SCRIPT_DIR/../programs.txt" | xargs sudo pacman -S --needed --noconfirm
echo "Package installation complete!"
echo ""

# Build and install dwl and slstatus from patched source
# TODO: Replace slstatus (X11) with dwlb (Wayland-native): https://github.com/kolunmi/dwlb

# Ensure /usr/local directory structure exists
sudo mkdir -p /usr/local/bin
sudo mkdir -p /usr/local/share/man/man1

echo "Building and installing slstatus..."
if [ -d "${HOME}/.local/src/slstatus" ]; then
    (
        cd "${HOME}/.local/src/slstatus"
        [ -f config.h ] && yes|rm config.h
        sudo make install
    )
    echo "slstatus installed successfully!"
else
    echo "WARNING: slstatus source not found at ${HOME}/.local/src/slstatus/"
    echo "Skipping slstatus installation."
fi

echo "Building and installing dwl..."
if [ -d "${HOME}/.local/src/dwl" ]; then
    (
        cd "${HOME}/.local/src/dwl"
        [ -f config.h ] && yes|rm config.h
        sudo make install
    )
    echo "dwl installed successfully!"
else
    echo "WARNING: dwl source not found at ${HOME}/.local/src/dwl/"
    echo "Skipping dwl installation."
fi

# Install dwl status click handler
echo "Installing status bar click handler..."
mkdir -p ${HOME}/.local/bin
cp "$SCRIPT_DIR/../dwl-status-click.sh" ${HOME}/.local/bin/
chmod +x ${HOME}/.local/bin/dwl-status-click.sh
echo "Click handler installed successfully!"

# Stow system configs
#cd "$REPO_ROOT/root" && sudo stow -t / .

# Enable and start system services
echo ""
echo "Enabling and starting system services..."

# Network services
sudo systemctl enable --now NetworkManager && echo "  ✓ NetworkManager"
sudo systemctl enable --now systemd-resolved && echo "  ✓ systemd-resolved"
sudo systemctl enable --now iwd && echo "  ✓ iwd"

# Mirror list updater
sudo systemctl enable --now reflector && echo "  ✓ reflector"

# Location services for gammastep
if systemctl list-unit-files | grep -q '^geoclue.service'; then
    # Install geoclue config with gammastep permissions
    if [ -f "$HOME/system-config/etc/geoclue/geoclue.conf" ]; then
        sudo cp "$HOME/system-config/etc/geoclue/geoclue.conf" /etc/geoclue/geoclue.conf && echo "  ✓ geoclue config installed"
    fi
    sudo systemctl enable --now geoclue && echo "  ✓ geoclue"
fi

# SSD TRIM (recommended for SSD health)
sudo systemctl enable --now fstrim.timer && echo "  ✓ fstrim.timer"

# User services
echo "Enabling user services..."

# Audio stack
systemctl --user enable --now pipewire && echo "  ✓ pipewire"
systemctl --user enable --now pipewire-pulse && echo "  ✓ pipewire-pulse"
systemctl --user enable --now wireplumber && echo "  ✓ wireplumber"

# File syncing
systemctl --user enable --now syncthing && echo "  ✓ syncthing"

# System monitors (battery and temperature warnings)
systemctl --user enable --now battery-monitor.timer && echo "  ✓ battery-monitor.timer"
systemctl --user enable --now temp-monitor.timer && echo "  ✓ temp-monitor.timer"

echo "Service setup complete!"
echo ""
echo "Done! Reboot and dwl should start."
