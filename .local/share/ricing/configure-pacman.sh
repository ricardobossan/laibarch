#!/bin/bash
# Configure pacman keyring and enable parallel downloads

echo "Initializing pacman keyring..."
pacman-key --init
pacman-key --populate archlinux

echo "Updating keyring package..."
pacman -Sy --noconfirm archlinux-keyring

echo "Performing full system upgrade..."
pacman -Syu --noconfirm

echo "Enabling parallel downloads in pacman.conf..."
# Uncomment ParallelDownloads if commented, or add it if missing
if grep -q "^#ParallelDownloads" /etc/pacman.conf; then
    sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf
elif ! grep -q "^ParallelDownloads" /etc/pacman.conf; then
    sed -i '/^\[options\]/a ParallelDownloads = 5' /etc/pacman.conf
fi

echo "Pacman configured successfully!"
