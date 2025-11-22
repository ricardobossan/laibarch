#!/bin/bash
# Battery monitoring script - sends notifications at low battery levels

BATTERY_PATH="/sys/class/power_supply/BAT0"
# Fallback to BAT1 if BAT0 doesn't exist
[ ! -d "$BATTERY_PATH" ] && BATTERY_PATH="/sys/class/power_supply/BAT1"

if [ ! -d "$BATTERY_PATH" ]; then
    exit 1
fi

CAPACITY=$(cat "$BATTERY_PATH/capacity")
STATUS=$(cat "$BATTERY_PATH/status")

# Only warn if discharging
if [ "$STATUS" != "Discharging" ]; then
    exit 0
fi

# State file to avoid spamming notifications
STATE_FILE="/tmp/battery-monitor-state"
LAST_STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "normal")

if [ "$CAPACITY" -le 10 ]; then
    if [ "$LAST_STATE" != "critical" ]; then
        notify-send -u critical "Battery Critical!" "Battery at ${CAPACITY}% - Plug in immediately!"
        echo "critical" > "$STATE_FILE"
    fi
elif [ "$CAPACITY" -le 20 ]; then
    if [ "$LAST_STATE" != "warning" ] && [ "$LAST_STATE" != "critical" ]; then
        notify-send -u normal "Battery Low" "Battery at ${CAPACITY}% - Consider plugging in"
        echo "warning" > "$STATE_FILE"
    fi
else
    echo "normal" > "$STATE_FILE"
fi
