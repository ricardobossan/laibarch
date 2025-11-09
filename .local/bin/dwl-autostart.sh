#!/bin/sh
# This runs after dwl has started and WAYLAND_DISPLAY is set

# Configure displays
~/.local/bin/configure-displays.sh

swww-daemon --no-cache &

swww img ~/laibarch.png --resize fit
