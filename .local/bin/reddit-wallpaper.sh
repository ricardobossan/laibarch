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
  if command -v awww &>/dev/null; then
    awww img "$DEFAULT_WALLPAPER" --resize fit --transition-type fade --transition-duration 2
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
    awww img "$DEFAULT_WALLPAPER" --resize fit 2>/dev/null
    return 1
  fi
  log "Fetching nature wallpaper from Unsplash"
  UNSPLASH_JSON=$(curl -s \
    -H "Authorization: Client-ID $key" \
    "https://api.unsplash.com/topics/nature/photos?per_page=30&orientation=landscape&order_by=popular")
  UNSPLASH_URL=$(echo "$UNSPLASH_JSON" | jq -r '.[].urls.raw' 2>/dev/null | shuf -n 1)
  if [ -z "$UNSPLASH_URL" ] || [ "$UNSPLASH_URL" = "null" ]; then
    log "ERROR: Failed to fetch Unsplash image, using default wallpaper"
    awww img "$DEFAULT_WALLPAPER" --resize fit 2>/dev/null
    return 1
  fi
  UNSPLASH_URL="${UNSPLASH_URL}&w=3840&fm=jpg&q=85&fit=max"
  log "Selected Unsplash image: $UNSPLASH_URL"
  if wget -q -O "$CACHE_FILE" "$UNSPLASH_URL"; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    cp "$CACHE_FILE" "$WALLPAPER_DIR/unsplash_${TIMESTAMP}.jpg"
    awww img "$CACHE_FILE" --transition-type fade --transition-duration 2
    log "Unsplash wallpaper set successfully"
  else
    log "ERROR: Failed to download Unsplash image, using default wallpaper"
    awww img "$DEFAULT_WALLPAPER" --resize fit 2>/dev/null
    return 1
  fi
}

log "Starting wallpaper fetch from r/earthporn"

# Load Reddit OAuth credentials from config file
REDDIT_CREDS="$HOME/.config/wallpaper/reddit-credentials"
if [ -f "$REDDIT_CREDS" ]; then
  # shellcheck source=/dev/null
  . "$REDDIT_CREDS"
fi
CLIENT_ID="${REDDIT_CLIENT_ID:-}"
CLIENT_SECRET="${REDDIT_CLIENT_SECRET:-}"

if [ -z "$CLIENT_ID" ] || [ -z "$CLIENT_SECRET" ]; then
  log "ERROR: Could not retrieve Reddit credentials from ~/.config/wallpaper/reddit-credentials, falling back to Unsplash"
  fetch_unsplash
  exit $?
fi

# Obtain OAuth token (client credentials grant — no user login needed for public data)
TOKEN=$(curl -s \
  -u "$CLIENT_ID:$CLIENT_SECRET" \
  -d "grant_type=client_credentials" \
  -A "linux:earthporn-wallpaper:v1.0 (by /u/wallpaper_script)" \
  "https://www.reddit.com/api/v1/access_token" | jq -r '.access_token')

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
  log "ERROR: Failed to obtain Reddit OAuth token, falling back to Unsplash"
  fetch_unsplash
  exit $?
fi

# Fetch top posts from r/earthporn (top of the week) via OAuth endpoint
JSON=$(curl -s \
  -A "linux:earthporn-wallpaper:v1.0 (by /u/wallpaper_script)" \
  -H "Authorization: bearer $TOKEN" \
  "https://oauth.reddit.com/r/earthporn/top?limit=50&t=week")

if [ -z "$JSON" ]; then
  log "ERROR: Failed to fetch data from Reddit, falling back to Unsplash"
  fetch_unsplash
  exit $?
fi

# Extract image URLs (filter for direct image links and 4K+ resolution)
URLS=$(echo "$JSON" | jq -r '.data.children[].data | select(.post_hint == "image") | select(.preview.images[0].source.width >= 3840) | .url' | grep -E '\.(jpg|png)$|i\.redd\.it')

if [ -z "$URLS" ]; then
  log "WARNING: No 4K images found, relaxing resolution filter"
  URLS=$(echo "$JSON" | jq -r '.data.children[].data | select(.post_hint == "image") | .url' | grep -E '\.(jpg|png)$|i\.redd\.it')
fi

if [ -z "$URLS" ]; then
  log "WARNING: No Reddit images found, falling back to Unsplash"
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
    awww img "$CACHE_FILE" --transition-type fade --transition-duration 2
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
