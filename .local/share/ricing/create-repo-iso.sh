#!/bin/bash
# Helper script to create an ISO image containing the laibarch repository
# This ISO can be attached to VMs or used as a physical installation medium

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "========================================"
echo "  Build Repository ISO"
echo "========================================"
echo ""

# Determine the repository root (parent of .local/share/ricing)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Default output location and filename
OUTPUT_DIR="${REPO_ROOT}"
OUTPUT_FILE="laibarch-repo.iso"

# Check if genisoimage or mkisofs is available
if command -v genisoimage &> /dev/null; then
    ISO_CMD="genisoimage"
elif command -v mkisofs &> /dev/null; then
    ISO_CMD="mkisofs"
else
    echo -e "${YELLOW}ERROR: Neither genisoimage nor mkisofs found${NC}"
    echo "Install one of them:"
    echo "  Arch: sudo pacman -S cdrtools"
    echo "  Debian/Ubuntu: sudo apt install genisoimage"
    exit 1
fi

echo "Using ISO creation tool: $ISO_CMD"
echo "Repository root: $REPO_ROOT"
echo ""

# Ensure git submodules are initialized (plugins, etc.)
if [ -f "$REPO_ROOT/.gitmodules" ]; then
    echo "Initializing git submodules..."
    git -C "$REPO_ROOT" submodule update --init --recursive
    echo ""
fi

# Allow custom output location
read -p "Output directory [$OUTPUT_DIR]: " CUSTOM_OUTPUT_DIR
if [ -n "$CUSTOM_OUTPUT_DIR" ]; then
    OUTPUT_DIR="$CUSTOM_OUTPUT_DIR"
fi

read -p "Output filename [$OUTPUT_FILE]: " CUSTOM_OUTPUT_FILE
if [ -n "$CUSTOM_OUTPUT_FILE" ]; then
    OUTPUT_FILE="$CUSTOM_OUTPUT_FILE"
fi

OUTPUT_PATH="$OUTPUT_DIR/$OUTPUT_FILE"

# Confirm before proceeding
echo ""
echo "Creating ISO with the following settings:"
echo "  Source: $REPO_ROOT"
echo "  Output: $OUTPUT_PATH"
echo ""
read -p "Continue? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ]; then
    echo "Cancelled"
    exit 0
fi

echo ""
echo "Building ISO..."
echo ""

# Create the ISO, including .git directory for full repository functionality
$ISO_CMD -o "$OUTPUT_PATH" \
    -R \
    -J \
    -V "LAIBARCH" \
    -volset "Laibarch Repository" \
    -A "Laibarch Arch Linux Rice" \
    -input-charset utf-8 \
    "$REPO_ROOT"

echo ""
echo -e "${GREEN}✓ ISO created successfully!${NC}"
echo ""
echo "ISO file: $OUTPUT_PATH"
ls -lh "$OUTPUT_PATH"
echo ""
echo -e "${BLUE}Usage:${NC}"
cat <<'EOF'

Complete installation workflow:

1. Boot from official Arch ISO
2. Attach this ISO as second CD-ROM (VMs) or USB (physical)
3. Mount repository (use /repo, NOT under /mnt):
   mkdir /repo && mount /dev/sr1 /repo  # check device with lsblk

4. Run installation (Phase 1 - auto-detected):
   bash /repo/.local/share/ricing/laibarch-install.sh

5. Reboot, login as root, mount repo again:
   mount /dev/sr0 /repo
   bash /repo/.local/share/ricing/laibarch-install.sh  # Phase 2

6. Reboot - DWL starts automatically

For VMs (libvirt): Attach via virt-manager or add to VM XML
For physical: Write to USB or burn to CD/DVD

EOF
