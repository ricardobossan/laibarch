#!/bin/sh
# This runs after dwl has started and WAYLAND_DISPLAY is set

# Set standard display variables if they aren't already set by the login manager
export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-0}
export DISPLAY=${DISPLAY:-:0} # This might need adjustment if you have multiple X sessions

# Prefer discrete GPU
export DRI_PRIME=1

# Update D-Bus activation environment for both Wayland and X variables
dbus-update-activation-environment WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP

# Dynamic display configuration
kanshi &

# Configure displays
~/.local/bin/configure-displays.sh

# Start notification daemon
mako &

# Clipboard management
wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &
wl-clip-persist --clipboard both &

# Auto-mount removable drives
udiskie &

swww-daemon --no-cache &

# Set wallpaper from Reddit
~/.local/bin/reddit-wallpaper.sh &

# Idle management - screen blanking and lock
# Suspend skipped if file transfer (cp/rsync/mv) or torrent daemon running
swayidle -w \
  timeout 300 'brightnessctl set 0' \
  timeout 330 'swaylock -f' \
  timeout 900 'pgrep -x cp || pgrep -x rsync || pgrep -x mv || pgrep -x transmission-da || systemctl suspend' \
  resume 'brightnessctl set 100%' \
  before-sleep 'swaylock -f' &

# Auto-adjust color temperature based on time of day
(
  LOCATION=$(curl -s --max-time 5 "https://api.positon.xyz/v1/geolocate?key=56aba903-ae67-4f26-919b-15288b44bda9" \
    -d '{"considerIp": true}' -H "Content-Type: application/json" 2>/dev/null |
    grep -o '"lat":[^,]*,"lng":[^}]*' | sed 's/"lat":\([^,]*\),"lng":\(.*\)/\1:\2/')
  gammastep -l ${LOCATION:--15.78:-47.93} -t 6500:2600
) &
