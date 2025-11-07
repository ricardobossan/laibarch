#!/bin/sh
# Auto-configure displays: prefer external monitor if available

# Check if external monitor (HDMI-A-1) is connected
if wlr-randr | grep -q "^HDMI-A-1"; then
    # External monitor is connected - use only external
    wlr-randr --output eDP-1 --off --output HDMI-A-1 --on --preferred
else
    # No external monitor - use laptop screen
    wlr-randr --output eDP-1 --on --preferred
fi
