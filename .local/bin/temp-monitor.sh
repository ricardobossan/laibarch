#!/bin/bash
# Temperature monitoring script - warns on overheating (>90°C)

THRESHOLD=90000  # 90°C in millidegrees

# Find the highest temperature from thermal zones
MAX_TEMP=0
ZONE_NAME=""

for zone in /sys/class/thermal/thermal_zone*/; do
    if [ -f "${zone}temp" ]; then
        TEMP=$(cat "${zone}temp" 2>/dev/null || echo 0)
        if [ "$TEMP" -gt "$MAX_TEMP" ]; then
            MAX_TEMP=$TEMP
            ZONE_NAME=$(cat "${zone}type" 2>/dev/null || echo "unknown")
        fi
    fi
done

# Convert to Celsius
TEMP_C=$((MAX_TEMP / 1000))

# State file to avoid spamming
STATE_FILE="/tmp/temp-monitor-state"
LAST_STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "normal")

if [ "$MAX_TEMP" -ge "$THRESHOLD" ]; then
    if [ "$LAST_STATE" != "overheat" ]; then
        # Red color using pango markup (if your notification daemon supports it)
        notify-send -u critical "OVERHEATING!" "<span color='#FF0000'><b>Temperature: ${TEMP_C}°C</b></span>\nSource: $ZONE_NAME\nClose applications or improve cooling!"
        echo "overheat" > "$STATE_FILE"
    fi
else
    echo "normal" > "$STATE_FILE"
fi
