#!/bin/bash
# Laibarch: Encrypted Arch Installation
# Run this from the Arch Live ISO BEFORE the system is installed
# This script performs base system installation with LUKS encryption

set -e # Exit on error

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

cat <<EOF
========================================
  Laibarch: Encrypted Arch Installation
========================================

EOF
echo -e "${RED}WARNING: This script will ERASE the target disk!${NC}"
echo -e "${YELLOW}Review the script before proceeding.${NC}"
echo ""
read -p "Have you reviewed this script and understand what it does? (type 'yes'): " REVIEWED
if [ "$REVIEWED" != "yes" ]; then
  echo "Please review the script before running."
  exit 0
fi
echo ""

# Check if running from live environment (not installed system)
if [ -d /run/archiso ]; then
  echo -e "${GREEN}✓ Running from Arch live environment${NC}"
else
  echo -e "${RED}ERROR: This script must be run from the Arch live ISO${NC}"
  echo "Boot from the installation media first"
  exit 1
fi

# Auto-detect installation target disk
echo "Step 1: Detecting installation target disk..."
echo "----------------------------------------"
lsblk -d -o NAME,SIZE,TYPE,ROTA | grep disk
echo ""

if [ -b /dev/vda ]; then
  DISK="/dev/vda"
  BOOT_PART="${DISK}1"
  ROOT_PART="${DISK}2"
  echo -e "${GREEN}Detected VM disk: $DISK${NC}"
elif [ -b /dev/nvme0n1 ]; then
  DISK="/dev/nvme0n1"
  BOOT_PART="${DISK}p1"
  ROOT_PART="${DISK}p2"
  echo -e "${GREEN}Detected NVMe disk: $DISK${NC}"
elif [ -b /dev/sda ]; then
  # Check if sda is not a USB drive
  if lsblk -d -o NAME,TRAN /dev/sda 2>/dev/null | grep -q "usb"; then
    echo -e "${YELLOW}WARNING: /dev/sda appears to be a USB drive${NC}"
    echo "Looking for alternative disk..."
    if [ -b /dev/sdb ]; then
      DISK="/dev/sdb"
      BOOT_PART="${DISK}1"
      ROOT_PART="${DISK}2"
      echo -e "${GREEN}Using alternative disk: $DISK${NC}"
    else
      echo -e "${RED}ERROR: No suitable disk found${NC}"
      exit 1
    fi
  else
    DISK="/dev/sda"
    BOOT_PART="${DISK}1"
    ROOT_PART="${DISK}2"
    echo -e "${GREEN}Detected SATA/IDE disk: $DISK${NC}"
  fi
else
  echo -e "${RED}ERROR: No suitable installation disk found${NC}"
  exit 1
fi

echo ""
echo "Installation target:"
echo "  Disk: $DISK"
echo "  Boot partition: $BOOT_PART"
echo "  Root partition: $ROOT_PART"
echo ""
lsblk "$DISK" 2>/dev/null || true
echo ""
echo -e "${RED}THIS WILL ERASE ALL DATA ON $DISK${NC}"
read -p "Continue with this disk? (type 'YES' to continue): " CONFIRM

if [ "$CONFIRM" != "YES" ]; then
  echo "Installation cancelled"
  exit 0
fi
echo ""

# Verify internet connection
echo "Step 2: Verifying internet connection..."
echo "----------------------------------------"
if ping -c 1 archlinux.org &>/dev/null; then
  echo -e "${GREEN}✓ Internet connection active${NC}"
else
  echo -e "${RED}ERROR: No internet connection${NC}"
  echo "Connect to WiFi using: iwctl"
  echo "  device list"
  echo "  station wlan0 scan"
  echo "  station wlan0 get-networks"
  echo "  station wlan0 connect \"SSID\""
  exit 1
fi
echo ""

# Update system clock
echo "Step 3: Updating system clock..."
echo "----------------------------------------"
timedatectl set-ntp true
timedatectl status
echo ""

# Partition the disk
echo "Step 4: Partitioning disk $DISK..."
echo "----------------------------------------"
echo "Wiping existing partitions..."
wipefs -af "$DISK" || true
sgdisk --zap-all "$DISK" || true

echo "Creating new GPT partition table..."
parted -s "$DISK" mklabel gpt

echo "Creating EFI partition (1GB)..."
parted -s "$DISK" mkpart ESP fat32 1MiB 1GiB
parted -s "$DISK" set 1 esp on

echo "Creating root partition (remaining space)..."
parted -s "$DISK" mkpart primary ext4 1GiB 100%

# Inform kernel of partition changes
partprobe "$DISK"
sleep 2

lsblk "$DISK"
echo ""

# Format boot partition
echo "Step 5: Formatting boot partition..."
echo "----------------------------------------"
mkfs.fat -F32 "$BOOT_PART"
echo -e "${GREEN}✓ Boot partition formatted${NC}"
echo ""

# Setup LUKS encryption
echo "Step 6: Setting up LUKS encryption..."
echo "----------------------------------------"
echo -e "${YELLOW}You will be asked to create an encryption password${NC}"
echo -e "${YELLOW}This password will be required every time you boot${NC}"
echo -e "${BLUE}Choose a strong password and remember it!${NC}"
echo ""
cryptsetup luksFormat "$ROOT_PART"

echo ""
echo "Opening encrypted partition..."
cryptsetup open "$ROOT_PART" cryptroot

echo "Formatting encrypted partition..."
mkfs.ext4 /dev/mapper/cryptroot
echo -e "${GREEN}✓ Encryption setup complete${NC}"
echo ""

# Mount filesystems
echo "Step 7: Mounting filesystems..."
echo "----------------------------------------"
mount /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot
mount "$BOOT_PART" /mnt/boot
echo -e "${GREEN}✓ Filesystems mounted${NC}"
lsblk
echo ""

# Configure pacman for faster downloads
echo "Step 8: Configuring pacman..."
echo "----------------------------------------"
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
echo -e "${GREEN}✓ Parallel downloads enabled${NC}"
echo ""

# Install base system
echo "Step 9: Installing base system..."
echo "----------------------------------------"
echo "This will take several minutes..."
pacstrap -K /mnt base base-devel linux linux-firmware \
  iwd nano vim networkmanager lvm2 cryptsetup efibootmgr \
  less man-db
echo -e "${GREEN}✓ Base system installed${NC}"
echo ""

# Generate fstab
echo "Step 10: Generating fstab..."
echo "----------------------------------------"
genfstab -U /mnt >>/mnt/etc/fstab
cat /mnt/etc/fstab
echo ""

# Configure the system (via chroot)
echo "Step 11: Configuring system..."
echo "----------------------------------------"

# Determine script directory (we're running from live ISO, mounted repo)
# SCRIPT_DIR should be set at the top of encrypted-arch-install.sh
CHROOT_SCRIPT="chroot-configure.sh"

# Find the chroot configuration script
if [ -n "$SCRIPT_DIR" ]; then
  CHROOT_SCRIPT_PATH="$SCRIPT_DIR/chroot-configure.sh"
else
  # Fallback: assume we're in the scripts directory
  CHROOT_SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)/chroot-configure.sh"
fi

if [ ! -f "$CHROOT_SCRIPT_PATH" ]; then
  echo -e "${RED}ERROR: Chroot configuration script not found at $CHROOT_SCRIPT_PATH${NC}"
  exit 1
fi

# Copy chroot configuration script to mounted system
cp "$CHROOT_SCRIPT_PATH" /mnt/chroot-configure.sh
chmod +x /mnt/chroot-configure.sh

echo "Entering chroot environment..."
echo ""
arch-chroot /mnt /chroot-configure.sh

# Clean up
rm /mnt/chroot-configure.sh

echo ""
echo -e "${GREEN}✓ System configuration complete${NC}"
echo ""

# Unmount and finish
echo "Step 12: Unmounting filesystems..."
echo "----------------------------------------"
umount -R /mnt
cryptsetup close cryptroot
echo -e "${GREEN}✓ Filesystems unmounted${NC}"
echo ""

cat <<'EOF'
========================================
  Base Installation Complete!
========================================

Base installation finished! Next steps:

  1. Remove installation media
  2. Reboot: reboot
  3. Boot into new system (will prompt for encryption password)
  4. Login as root
  5. Mount your repository ISO/share containing laibarch:
     mkdir /repo
     mount /dev/sr0 /repo  (for ISO)
  6. Run: bash /repo/.local/share/ricing/laibarch-install.sh

EOF
echo -e "${YELLOW}IMPORTANT: Keep your repository ISO/share available!${NC}"
echo ""
echo -e "${BLUE}NOTE: Auto-login configuration should be done in your private${NC}"
echo -e "${BLUE}personal configs, not in the public installation.${NC}"
echo ""
