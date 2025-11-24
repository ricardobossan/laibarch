#!/bin/bash
# Additional applications (gaming, etc.)
# Run after main installation is complete

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

cat <<'EOF'
========================================
  Additional Applications
========================================

This will install:
  - Steam (via Flatpak with XWayland)

EOF

read -p "Install additional applications? (y/n): " INSTALL_ADDITIONAL
if [ "$INSTALL_ADDITIONAL" != "y" ]; then
    echo "Skipping additional applications."
    exit 0
fi

echo ""
echo "Setting up Flatpak..."
echo "--------------------------------"

# Add Flathub repository if not already added
if ! flatpak remotes | grep -q flathub; then
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo "✓ Flathub repository added"
else
    echo "✓ Flathub repository already configured"
fi

echo ""
echo "Installing Steam..."
echo "--------------------------------"

flatpak install -y flathub com.valvesoftware.Steam
echo "✓ Steam installed"

cat <<'EOF'

========================================
  Additional Applications Installed!
========================================

Steam launchers (already in ~/.local/bin/):
  steam   - Uses Gamescope (recommended)
  xsteam  - Uses XWayland (for games with input issues like ETS2)

EOF
