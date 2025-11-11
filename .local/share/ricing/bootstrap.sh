#!/bin/bash
# Simple bootstrap for fresh Arch install
# Run from: ~/source/repos/laibarch-deprecated/scripts/bootstrap.sh

# Build and install dwl and slstatus from patched source
echo "Building and installing slstatus..."
sudo make -C ${HOME}/.local/src/slstatus/ clean install
echo "Building and installing dwl..."
sudo make -C ${HOME}/.local/src/dwl/ clean install
echo "dwl and slstatus installed successfully!"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Install dwl status click handler
echo "Installing status bar click handler..."
mkdir -p ${HOME}/.local/bin
cp "$REPO_ROOT/ricing/dwl-status-click.sh" ${HOME}/.local/bin/
chmod +x ${HOME}/.local/bin/dwl-status-click.sh
echo "Click handler installed successfully!"

# Install yay, brave, neovim
bash "$REPO_ROOT/ricing/programs-scripts.sh"

# Install everything from programs.txt with pacman
echo "Installing packages from programs.txt..."
# Clean the file: remove empty lines and whitespace, then install all at once
grep -v '^[[:space:]]*$' "$REPO_ROOT/ricing/programs.txt" | xargs sudo pacman -S --needed --noconfirm
echo "Package installation complete!"

# Stow system configs
#cd "$REPO_ROOT/root" && sudo stow -t / .

# Enable and start system services
echo ""
echo "Enabling and starting system services..."

# Network services
sudo systemctl enable --now NetworkManager && echo "  ✓ NetworkManager"
sudo systemctl enable --now systemd-resolved && echo "  ✓ systemd-resolved"

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

echo "Service setup complete!"
echo ""
echo "Done! Reboot and dwl should start."
