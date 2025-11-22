#!/bin/bash
# Laibarch Complete Installation Script
# Run this as ROOT from Arch Live ISO or after first boot
# This script handles both base installation and post-installation automatically

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run as root"
    echo "Usage: sudo bash laibarch-install.sh"
    exit 1
fi

# Detect if running from live ISO or installed system
if [ -d /run/archiso ]; then
    cat <<'EOF'
========================================
  Laibarch Complete Installation
  Phase 1: Base Installation
========================================

Detected: Running from Arch Live ISO

This will run the complete installation:
  Phase 1: Partition disk, setup LUKS, install base system
  (After reboot, run this script again for Phase 2)

EOF
    read -p "Continue with Phase 1? (y/n): " CONTINUE
    if [ "$CONTINUE" != "y" ]; then
        exit 0
    fi
    echo ""

    # Check/setup internet connection
    echo "Verifying internet connection..."
    if ping -c 1 archlinux.org &> /dev/null; then
        echo "✓ Internet connection active"
        echo ""
    else
        echo "No internet connection detected."
        echo ""
        echo "Connection options:"
        echo "  1. Ethernet (automatic - just plug cable)"
        echo "  2. WiFi (setup required)"
        echo ""
        read -p "Need to setup WiFi? (y/n): " SETUP_WIFI

        if [ "$SETUP_WIFI" = "y" ]; then
            echo ""
            echo "Setting up WiFi with iwd..."
            echo ""

            # Get WiFi device name
            WIFI_DEVICE=$(iwctl device list | grep -oP '^\s*\K\w+(?=\s+station)' | head -1)

            if [ -z "$WIFI_DEVICE" ]; then
                echo "No WiFi device found. Trying to unblock..."
                rfkill unblock wifi
                sleep 2
                WIFI_DEVICE=$(iwctl device list | grep -oP '^\s*\K\w+(?=\s+station)' | head -1)
            fi

            if [ -z "$WIFI_DEVICE" ]; then
                echo "ERROR: No WiFi device detected"
                exit 1
            fi

            echo "WiFi device: $WIFI_DEVICE"
            echo ""

            # Scan for networks
            echo "Scanning for networks..."
            iwctl station "$WIFI_DEVICE" scan
            sleep 3

            # Show available networks
            echo "Available networks:"
            iwctl station "$WIFI_DEVICE" get-networks
            echo ""

            # Connect
            read -p "Enter WiFi SSID: " WIFI_SSID

            if [ -z "$WIFI_SSID" ]; then
                echo "ERROR: SSID cannot be empty"
                exit 1
            fi

            echo "Connecting to $WIFI_SSID..."
            iwctl station "$WIFI_DEVICE" connect "$WIFI_SSID"

            sleep 3

            # Verify connection
            if ping -c 1 archlinux.org &> /dev/null; then
                echo "✓ Connected successfully"
                echo ""
            else
                echo "ERROR: Connection failed"
                exit 1
            fi
        else
            echo ""
            read -p "Press Enter after connecting to internet..."

            if ! ping -c 1 archlinux.org &> /dev/null; then
                echo "ERROR: No internet connection. Cannot proceed."
                exit 1
            fi
            echo "✓ Internet connection verified"
            echo ""
        fi
    fi

    # Run base installation
    bash "$SCRIPT_DIR/scripts/encrypted-arch-install.sh"

    # Script will exit here after base installation completes
    # User must reboot and run again
    exit 0
fi

cat <<'EOF'
========================================
  Laibarch Complete Installation
  Phase 2: Post-Installation
========================================

Detected: Running from installed system

This script will:
  - Create a new user account
  - Copy repository to user home
  - Install all packages and build DWL
  - Configure network backend (iwd)

EOF
read -p "Continue with Phase 2? (y/n): " CONTINUE
if [ "$CONTINUE" != "y" ]; then
    exit 0
fi
echo ""

# Step 1: Create user
echo "Step 1: User setup"
echo "--------------------------------"
read -p "Enter username: " NEW_USER

if [ -z "$NEW_USER" ]; then
    echo "ERROR: Username cannot be empty"
    exit 1
fi

# Check if user already exists
if id "$NEW_USER" &>/dev/null; then
    echo "User '$NEW_USER' already exists."
    read -p "Use existing user? (y/n): " USE_EXISTING
    if [ "$USE_EXISTING" != "y" ]; then
        echo "Installation cancelled."
        exit 0
    fi

    # Ensure user is in wheel group
    if ! groups "$NEW_USER" | grep -q wheel; then
        echo "Adding $NEW_USER to wheel group..."
        usermod -aG wheel "$NEW_USER"
    fi

    read -p "Update password for $NEW_USER? (y/n): " UPDATE_PASS
    if [ "$UPDATE_PASS" = "y" ]; then
        passwd "$NEW_USER"
    fi
else
    # Create new user with home directory, add to wheel group, set bash as shell
    echo "Creating user $NEW_USER..."
    useradd -mG wheel -s /bin/bash "$NEW_USER"

    # Set password for new user
    echo "Set password for user $NEW_USER:"
    passwd "$NEW_USER"
fi
echo ""

# Step 2: Setup repository in user's home
echo "Step 2: Setting up repository in user home..."
echo "--------------------------------"
# Get the repo root (three levels up: ricing -> share -> .local -> home)
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
USER_HOME="/home/$NEW_USER"

echo "DEBUG INFORMATION:"
echo "  SCRIPT_DIR: $SCRIPT_DIR"
echo "  REPO_ROOT: $REPO_ROOT"
echo "  USER_HOME: $USER_HOME"
echo "  REPO_ROOT has .git?: $([ -d "$REPO_ROOT/.git" ] && echo "YES" || echo "NO")"
echo "  USER_HOME has .git?: $([ -d "$USER_HOME/.git" ] && echo "YES" || echo "NO")"
echo ""
read -p "Press Enter to continue..."
echo ""

# Check if user's home is already a git repository
if [ -d "$USER_HOME/.git" ]; then
    echo "User home is already a git repository, skipping copy..."
else
    # Check if source is a git repository
    if [ ! -d "$REPO_ROOT/.git" ]; then
        echo "WARNING: Source ($REPO_ROOT) is not a git repository!"
        echo "Cannot setup git repository in user home."
        echo ""
        read -p "Press Enter to continue anyway..."
    else
        # Copy the entire repo structure to user's home, including .git
        echo "Copying repository files (including .git) from $REPO_ROOT to $USER_HOME..."
        # Use rsync if available, otherwise cp
        if command -v rsync &> /dev/null; then
            rsync -av "$REPO_ROOT/" "$USER_HOME/"
        else
            cp -r "$REPO_ROOT/." "$USER_HOME/"
        fi

        # Fix ownership
        chown -R "$NEW_USER:$NEW_USER" "$USER_HOME"

        echo "Repository copied successfully!"
    fi
fi

# Always ensure git safe directory is configured
if [ -d "$USER_HOME/.git" ]; then
    sudo -u "$NEW_USER" git -C "$USER_HOME" config --global --add safe.directory "$USER_HOME" 2>/dev/null || true
fi

echo ""

# Step 3: Configure pacman
echo "Step 3: Configuring pacman..."
echo "--------------------------------"
bash "$SCRIPT_DIR/scripts/configure-pacman.sh"
echo ""

# Step 4: Install packages and build DWL (as new user)
echo "Step 4: Installing packages and building DWL (as user $NEW_USER)..."
echo "--------------------------------"

# Run bootstrap script as the new user (with proper HOME)
echo "Running bootstrap..."
sudo -u "$NEW_USER" HOME="/home/$NEW_USER" bash "$SCRIPT_DIR/scripts/bootstrap.sh"

# Change user's default shell to zsh (now that it's installed)
echo "Setting zsh as default shell for $NEW_USER..."
chsh -s /bin/zsh "$NEW_USER"

# Run programs-scripts as the new user (with proper HOME)
echo "Installing additional programs from source..."
sudo -u "$NEW_USER" HOME="/home/$NEW_USER" bash "$SCRIPT_DIR/scripts/programs-scripts.sh"
echo ""

cat <<EOF
========================================
  Laibarch Installation Complete!
========================================

Installation finished! You can now:
  1. Reboot the system: reboot
  2. Login as user: $NEW_USER
  3. DWL should start automatically

NOTE: Auto-login configuration should be done in your private
personal-configs repository for additional security customization.

EOF
