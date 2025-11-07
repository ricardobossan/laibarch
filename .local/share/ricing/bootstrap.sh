#!/bin/bash
# Simple bootstrap for fresh Arch install
# Run from: ~/source/repos/laibarch-deprecated/scripts/bootstrap.sh

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

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
