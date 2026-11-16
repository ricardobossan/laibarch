#!/bin/bash

set -e

INSTALLER_URL="https://pkgs.netbird.io/install.sh"

tmp=$(mktemp -d)
trap 'rm -r "$tmp"' EXIT

echo "Downloading NetBird installer from $INSTALLER_URL..."
curl -fsSL --proto '=https' -o "$tmp/install.sh" "$INSTALLER_URL"
echo "SHA-256: $(sha256sum "$tmp/install.sh" | cut -d' ' -f1)"
echo "Saved at $tmp/install.sh (read it with: less $tmp/install.sh)"
echo ""

if command -v netbird &>/dev/null; then
    echo "NetBird already installed: $(netbird version 2>/dev/null)"
    action="update"
    args="--update"
else
    action="install"
    args=""
fi

read -p "Run the installer to $action NetBird (uses sudo)? (y/n): " answer
if [ "$answer" != "y" ]; then
    echo "Skipped."
    exit 0
fi

SKIP_UI_APP=true sh "$tmp/install.sh" ${args:+"$args"}

echo ""
echo "NetBird $(netbird version 2>/dev/null) installed; service: $(systemctl is-active netbird 2>/dev/null || echo unknown)"
echo "Next, on this machine only: sudo netbird up   (opens a browser login on first run)"
echo "Uninstall: sudo netbird service stop && sudo netbird service uninstall && sudo rm /usr/bin/netbird"
