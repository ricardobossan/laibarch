#!/bin/sh
# Universal brightness control for laptop (brightnessctl) and desktop (ddcutil)
# Usage: brightness.sh up|down [percent]

direction="$1"
percent="${2:-5}"

# Try brightnessctl first (laptop with backlight)
if brightnessctl -l 2>/dev/null | grep -q 'class.*backlight'; then
    case "$direction" in
        up)   brightnessctl set "${percent}%+" ;;
        down) brightnessctl set "${percent}%-" ;;
    esac
    exit 0
fi

# Fall back to ddcutil (desktop with external monitor via DDC/CI)
if command -v ddcutil >/dev/null 2>&1; then
    case "$direction" in
        up)   ddcutil setvcp 10 + "$percent" 2>/dev/null ;;
        down) ddcutil setvcp 10 - "$percent" 2>/dev/null ;;
    esac
    exit 0
fi

# No brightness control available
notify-send "Brightness" "No brightness control available"
exit 1
