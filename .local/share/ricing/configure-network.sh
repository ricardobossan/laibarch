#!/bin/bash
# Script to configure NetworkManager to use iwd instead of wpa_supplicant

echo "Configuring NetworkManager to use iwd backend..."

# Create conf.d directory if it doesn't exist
mkdir -p /etc/NetworkManager/conf.d

# Create the iwd backend configuration
cat > /etc/NetworkManager/conf.d/wifi-backend.conf << 'EOF'
[device]
# Use iwd as the WiFi backend instead of wpa_supplicant
wifi.backend=iwd
EOF

echo "Configuration file created."

# Stop and disable wpa_supplicant
echo "Stopping and disabling wpa_supplicant..."
systemctl stop wpa_supplicant
systemctl disable wpa_supplicant

# Restart NetworkManager
echo "Restarting NetworkManager..."
systemctl restart NetworkManager

echo "Done! NetworkManager is now using iwd."
echo "Your network connections should work as before."
