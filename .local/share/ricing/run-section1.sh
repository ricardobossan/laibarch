#!/bin/bash
# Master script for Section 1: Standard Setup
# Run this when user, internet, and pacman are already configured

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "========================================"
echo "  Section 1: Standard Setup"
echo "========================================"
echo ""

# Step 1: Bootstrap - build dwl/slstatus, install packages, enable services
echo "Step 1: Running bootstrap.sh..."
bash "$SCRIPT_DIR/bootstrap.sh"
echo ""

# Step 2: Install programs from source
echo "Step 2: Running programs-scripts.sh..."
bash "$SCRIPT_DIR/programs-scripts.sh"
echo ""

echo "========================================"
echo "  Section 1 Complete!"
echo "========================================"
echo ""
echo "Reboot to start DWL."
