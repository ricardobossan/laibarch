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

echo "Done! Reboot and dwl should start."
