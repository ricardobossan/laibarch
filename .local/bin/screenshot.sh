#!/bin/sh
# Screenshot script for dwl using grim and slurp
# Usage: screenshot.sh [fullscreen|selection|selection-clipboard|output]

SCREENSHOT_DIR="$HOME/Pictures/screenshots"
mkdir -p "$SCREENSHOT_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FILENAME="$SCREENSHOT_DIR/screenshot_$TIMESTAMP.png"

case "$1" in
    fullscreen)
        # Capture entire screen (all outputs)
        grim "$FILENAME" && \
        notify-send -u low "Screenshot" "Fullscreen saved to $FILENAME"
        ;;

    selection)
        # Interactive area selection, save to file
        GEOMETRY=$(slurp 2>/dev/null)
        if [ -n "$GEOMETRY" ]; then
            grim -g "$GEOMETRY" "$FILENAME" && \
            notify-send -u low "Screenshot" "Selection saved to $FILENAME"
        else
            notify-send -u critical "Screenshot" "Selection cancelled"
        fi
        ;;

    selection-clipboard)
        # Interactive area selection, copy to clipboard
        GEOMETRY=$(slurp 2>/dev/null)
        if [ -n "$GEOMETRY" ]; then
            grim -g "$GEOMETRY" - | wl-copy && \
            notify-send -u low "Screenshot" "Selection copied to clipboard"
        else
            notify-send -u critical "Screenshot" "Selection cancelled"
        fi
        ;;

    output)
        # Capture current output/monitor
        OUTPUT=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name' 2>/dev/null)
        if [ -z "$OUTPUT" ]; then
            # Fallback if swaymsg not available - just use fullscreen
            grim "$FILENAME" && \
            notify-send -u low "Screenshot" "Screen saved to $FILENAME"
        else
            grim -o "$OUTPUT" "$FILENAME" && \
            notify-send -u low "Screenshot" "Output saved to $FILENAME"
        fi
        ;;

    *)
        echo "Usage: $0 {fullscreen|selection|selection-clipboard|output}"
        exit 1
        ;;
esac
