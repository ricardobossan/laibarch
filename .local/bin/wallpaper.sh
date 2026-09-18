#!/bin/bash
# Download and set wallpaper from r/earthporn (primary) or Unsplash (fallback)

WALLPAPER_DIR="$HOME/.local/share/wallpapers/reddit"
CACHE_FILE="$HOME/.cache/wallpaper.jpg"
LOG_FILE="$HOME/.cache/wallpaper.log"
DEFAULT_WALLPAPER="$HOME/.local/share/laibarch.png"

# Create wallpaper directory if it doesn't exist
mkdir -p "$WALLPAPER_DIR"

# Set the wallpaper one output at a time. awww holds a multi-output request
# until every output acks its last frame, and dwl never sends that ack to a
# fully covered output (e.g. fullscreen video), so one hidden monitor would
# freeze the wallpaper on all of them.
set_wallpaper() {
  local outputs out
  outputs=$(awww query -j 2>/dev/null | jq -r '.[][].name')
  if [ -z "$outputs" ]; then
    awww img "$@"
    return
  fi
  for out in $outputs; do
    awww img -o "$out" "$@"
  done
}

# Check for 'default' argument to apply default wallpaper
if [ "$1" = "default" ]; then
  echo "Applying default wallpaper..."
  if command -v awww &>/dev/null; then
    set_wallpaper "$DEFAULT_WALLPAPER" --resize fit --transition-type fade --transition-duration 2
    echo "Default wallpaper set successfully"
  else
    echo "ERROR: awww not found"
    exit 1
  fi
  exit 0
fi

# Function to log messages
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >>"$LOG_FILE"
}

fetch_unsplash() {
  local key unsplash_creds="$HOME/.config/wallpaper/unsplash-credentials"
  if [ -f "$unsplash_creds" ]; then
    . "$unsplash_creds"
  fi
  key="${UNSPLASH_ACCESS_KEY:-}"
  if [ -z "$key" ]; then
    log "ERROR: Could not retrieve Unsplash key from ~/.config/wallpaper/unsplash-credentials, using default wallpaper"
    set_wallpaper "$DEFAULT_WALLPAPER" --resize fit 2>/dev/null
    return 1
  fi
  log "Fetching nature wallpaper from Unsplash"
  UNSPLASH_JSON=$(curl -s \
    -H "Authorization: Client-ID $key" \
    "https://api.unsplash.com/topics/nature/photos?per_page=30&orientation=landscape&order_by=popular")
  UNSPLASH_URL=$(echo "$UNSPLASH_JSON" | jq -r '.[].urls.raw' 2>/dev/null | shuf -n 1)
  if [ -z "$UNSPLASH_URL" ] || [ "$UNSPLASH_URL" = "null" ]; then
    log "ERROR: Failed to fetch Unsplash image, using default wallpaper"
    set_wallpaper "$DEFAULT_WALLPAPER" --resize fit 2>/dev/null
    return 1
  fi
  UNSPLASH_URL="${UNSPLASH_URL}&w=3840&fm=jpg&q=85&fit=max"
  log "Selected Unsplash image: $UNSPLASH_URL"
  if wget -q -O "$CACHE_FILE" "$UNSPLASH_URL"; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    cp "$CACHE_FILE" "$WALLPAPER_DIR/unsplash_${TIMESTAMP}.jpg"
    set_wallpaper "$CACHE_FILE" --transition-type fade --transition-duration 2
    log "Unsplash wallpaper set successfully"
  else
    log "ERROR: Failed to download Unsplash image, using default wallpaper"
    set_wallpaper "$DEFAULT_WALLPAPER" --resize fit 2>/dev/null
    return 1
  fi
}

log "Starting wallpaper fetch from r/earthporn"

# Fetch top posts from r/earthporn (top of the week) via the public RSS feed.
# The JSON API refuses anonymous requests, but the feed needs no credentials.
RSS=$(curl -sf \
  -A "linux:earthporn-wallpaper:v1.0 (by /u/wallpaper_script)" \
  "https://www.reddit.com/r/earthporn/top/.rss?t=week&limit=50")

if [ -z "$RSS" ]; then
  log "ERROR: Failed to fetch data from Reddit, falling back to Unsplash"
  fetch_unsplash
  exit $?
fi

# One line per direct image post: "<width> <height> <url>". The feed has no
# image sizes, but r/earthporn requires them in the title as [WxH].
POSTS=$(echo "$RSS" | awk 'BEGIN { RS = "<entry>" } NR > 1 {
  if (!match($0, /https:\/\/i\.redd\.it\/[^&"]+\.(jpe?g|png)/)) next
  url = substr($0, RSTART, RLENGTH)
  if (!match($0, /<title>[^<]*<\/title>/)) next
  title = substr($0, RSTART, RLENGTH)
  if (!match(title, /[0-9][0-9][0-9]+ *([xX]|×) *[0-9][0-9][0-9]+/)) next
  split(substr(title, RSTART, RLENGTH), size, /[^0-9]+/)
  print size[1], size[2], url
}')

# Extract image URLs (landscape only, since portrait shots get cropped to a
# thin strip, and 4K+ resolution when available)
URLS=$(echo "$POSTS" | awk '$1 >= 3840 && $1 > $2 { print $3 }')

if [ -z "$URLS" ]; then
  log "WARNING: No 4K images found, relaxing resolution filter"
  URLS=$(echo "$POSTS" | awk '$1 > $2 { print $3 }')
fi

if [ -z "$URLS" ]; then
  log "WARNING: No landscape Reddit images found, falling back to Unsplash"
  fetch_unsplash
  exit $?
fi

# Pick a random image from the list
RANDOM_URL=$(echo "$URLS" | shuf -n 1)
log "Selected image: $RANDOM_URL"

# Download the image
if wget -q -O "$CACHE_FILE" "$RANDOM_URL"; then
  log "Successfully downloaded wallpaper"

  # Save to wallpaper collection
  TIMESTAMP=$(date +%Y%m%d_%H%M%S)
  cp "$CACHE_FILE" "$WALLPAPER_DIR/reddit_${TIMESTAMP}.jpg"

  # Set as wallpaper using awww
  if command -v awww &>/dev/null; then
    set_wallpaper "$CACHE_FILE" --transition-type fade --transition-duration 2
    log "Wallpaper set successfully"
  else
    log "WARNING: awww not found, wallpaper downloaded but not set"
  fi
else
  log "ERROR: Failed to download wallpaper from $RANDOM_URL, falling back to Unsplash"
  fetch_unsplash
  exit $?
fi

# Keep only the last 10 wallpapers to save space
cd "$WALLPAPER_DIR" && ls -t | tail -n +11 | xargs -r rm --

log "Wallpaper update completed"
