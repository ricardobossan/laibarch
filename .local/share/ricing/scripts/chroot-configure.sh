#!/bin/bash
# Chroot configuration script for new Arch installation
# Run inside arch-chroot environment

set -e

echo "Configuring timezone..."
echo ""
echo "Common timezones:"
echo "  America/Sao_Paulo"
echo "  America/New_York"
echo "  Europe/London"
echo "  Asia/Tokyo"
echo ""
read -p "Enter timezone (e.g., America/Sao_Paulo): " TIMEZONE

if [ ! -f "/usr/share/zoneinfo/$TIMEZONE" ]; then
    echo "WARNING: Timezone not found. Using UTC."
    TIMEZONE="UTC"
fi

ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc
echo "Timezone set to: $TIMEZONE"

echo ""
echo "Configuring locale..."
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/^#pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/' /etc/locale.gen
locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf

echo ""
read -p "Enter hostname for this machine: " HOSTNAME
if [ -z "$HOSTNAME" ]; then
    HOSTNAME="archlinux"
    echo "Using default hostname: $HOSTNAME"
fi
echo "$HOSTNAME" > /etc/hostname

echo ""
echo "Setting root password..."
passwd

echo ""
echo "Configuring sudo for wheel group..."
# Uncomment the wheel group line in sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
echo "Wheel group configured for sudo access"

echo ""
echo "Configuring mkinitcpio for encryption..."
# Backup original
cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.backup

# Configure hooks for systemd-based encryption
sed -i 's/^HOOKS=.*/HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block sd-encrypt lvm2 filesystems fsck)/' /etc/mkinitcpio.conf

echo "Regenerating initramfs..."
mkinitcpio -P

echo ""
echo "Enabling NetworkManager..."
systemctl enable NetworkManager

echo ""
echo "Configuring NetworkManager to use iwd backend..."
mkdir -p /etc/NetworkManager/conf.d
cat > /etc/NetworkManager/conf.d/wifi-backend.conf << 'EOF'
[device]
# Use iwd as the WiFi backend instead of wpa_supplicant
wifi.backend=iwd
EOF
echo "iwd backend configured"

echo ""
echo "Installing systemd-boot..."
bootctl install

echo ""
echo "Configuring bootloader..."
# Get UUID of the encrypted partition (not the mapper)
ROOT_UUID=$(lsblk -dno UUID $(cryptsetup status cryptroot | grep device: | awk '{print $2}'))

cat > /boot/loader/entries/arch.conf << EOF
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options rd.luks.name=${ROOT_UUID}=cryptroot root=/dev/mapper/cryptroot rw quiet
EOF

echo "Bootloader configured with UUID: $ROOT_UUID"

# Verify bootctl configuration
echo ""
echo "Verifying bootloader configuration..."
bootctl
