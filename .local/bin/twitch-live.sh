#!/usr/bin/env bash

config="$HOME/.config/twitch-live/twitch-live-config.yaml"
playlist="/tmp/twitch-live.m3u"

if [ ! -f "$config" ]; then
    echo "Config file not found: $config"
    exit 1
fi

# Extract channel list
mapfile -t channels < <(grep -E '^\s*-' "$config" | sed -E 's/^\s*-\s*//')

if [ ${#channels[@]} -eq 0 ]; then
    echo "No channels found in config file."
    exit 1
fi

# Build playlist file
: > "$playlist"
for channel in "${channels[@]}"; do
    echo "https://www.twitch.tv/$channel" >> "$playlist"
done

echo "Playlist written to $playlist"
echo "Launching mpv…"

# Run mpv with playlist
mpv --really-quiet --no-terminal --loop-playlist --playlist="$playlist"

