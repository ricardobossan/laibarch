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

swww img ~/laibarch.png --resize fit

# Auto-adjust color temperature based on time of day
gammastep -l geoclue2 -t 6500:2600 &
