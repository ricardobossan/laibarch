#!/bin/bash
# Download and set wallpaper from r/earthporn

WALLPAPER_DIR="$HOME/.local/share/wallpapers/reddit"
CACHE_FILE="$HOME/.cache/reddit_wallpaper.jpg"
LOG_FILE="$HOME/.cache/reddit_wallpaper.log"
DEFAULT_WALLPAPER="$HOME/.local/share/laibarch.png"

# Create wallpaper directory if it doesn't exist
mkdir -p "$WALLPAPER_DIR"

# Check for 'default' argument to apply default wallpaper
if [ "$1" = "default" ]; then
    echo "Applying default wallpaper..."
    if command -v swww &> /dev/null; then
        swww img "$DEFAULT_WALLPAPER" --resize fit --transition-type fade --transition-duration 2
        echo "Default wallpaper set successfully"
    else
        echo "ERROR: swww not found"
        exit 1
    fi
    exit 0
fi

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log "Starting wallpaper fetch from r/earthporn"

# Fetch top posts from r/earthporn (top of the week)
# Using User-Agent to avoid Reddit blocking
JSON=$(curl -s -A "linux:earthporn-wallpaper:v1.0 (by /u/wallpaper_script)" \
    "https://www.reddit.com/r/earthporn/top.json?limit=50&t=week")

if [ -z "$JSON" ]; then
    log "ERROR: Failed to fetch data from Reddit, using default wallpaper"
    swww img "$DEFAULT_WALLPAPER" --resize fit 2>/dev/null
    exit 1
fi

# Extract image URLs (filter for direct image links and high resolution)
# Looking for .jpg, .png, and i.redd.it links
URLS=$(echo "$JSON" | jq -r '.data.children[].data | select(.post_hint == "image") | .url' | grep -E '\.(jpg|png)$|i\.redd\.it')

if [ -z "$URLS" ]; then
    log "ERROR: No image URLs found, using default wallpaper"
    swww img "$DEFAULT_WALLPAPER" --resize fit 2>/dev/null
    exit 1
fi

# Pick a random image from the list
RANDOM_URL=$(echo "$URLS" | shuf -n 1)
log "Selected image: $RANDOM_URL"

# Download the image
if wget -q -O "$CACHE_FILE" "$RANDOM_URL"; then
    log "Successfully downloaded wallpaper"

    # Optional: Save to wallpaper collection
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    cp "$CACHE_FILE" "$WALLPAPER_DIR/reddit_${TIMESTAMP}.jpg"

    # Set as wallpaper using swww
    if command -v swww &> /dev/null; then
        swww img "$CACHE_FILE" --transition-type fade --transition-duration 2
        log "Wallpaper set successfully"
    else
        log "WARNING: swww not found, wallpaper downloaded but not set"
    fi
else
    log "ERROR: Failed to download wallpaper from $RANDOM_URL, using default wallpaper"
    swww img "$DEFAULT_WALLPAPER" --resize fit 2>/dev/null
    exit 1
fi

# Keep only the last 10 wallpapers to save space
cd "$WALLPAPER_DIR" && ls -t | tail -n +11 | xargs -r rm --

log "Wallpaper update completed"
