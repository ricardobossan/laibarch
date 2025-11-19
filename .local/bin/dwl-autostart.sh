#!/bin/sh
# This runs after dwl has started and WAYLAND_DISPLAY is set

# Configure displays
~/.local/bin/configure-displays.sh

# Start notification daemon
mako &

# Clipboard management
wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &
wl-clip-persist --clipboard both &

swww-daemon --no-cache &

# Set wallpaper from Reddit
~/.local/bin/reddit-wallpaper.sh &

# Auto-adjust color temperature based on time of day
(
  LOCATION=$(curl -s --max-time 5 "https://api.positon.xyz/v1/geolocate?key=56aba903-ae67-4f26-919b-15288b44bda9" \
    -d '{"considerIp": true}' -H "Content-Type: application/json" 2>/dev/null |
    grep -o '"lat":[^,]*,"lng":[^}]*' | sed 's/"lat":\([^,]*\),"lng":\(.*\)/\1:\2/')
  gammastep -l ${LOCATION:--15.78:-47.93} -t 6500:2600
) &
