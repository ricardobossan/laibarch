#!/bin/sh
# dwl autostart script
# This runs after dwl has started and WAYLAND_DISPLAY is set

# Wait briefly for dwl to be fully ready
sleep 1

# Configure displays
~/.local/bin/configure-displays.sh

# Start waybar
waybar &
