#cat > build-core.sh <<'EOF'
#!/bin/bash
set -euo pipefail

CITY="${1:-}"
MIN_ZOOM="${2:-4}"
MAX_ZOOM="${3:-10}"
SOURCE="${4:-terrain}"
CARD_NAME="${5:-}"

cd ~/tdeck-maps

# Auto-detect SD card if not provided
if [ -z "$CARD_NAME" ]; then
  CARD_NAME=$(ls /Volumes | grep -E "TDECK|NO NAME|UNTITLED" | head -n 1 || true)
fi

if [ -z "$CARD_NAME" ]; then
  echo "ERROR: No SD card found in /Volumes"
  ls /Volumes
  exit 1
fi

echo "Using SD card: $CARD_NAME"

rm -rf tiles

if [ -n "$CITY" ]; then
  echo "Building for city: $CITY"
  python3 meshtastic_tiles.py \
    --city "$CITY" \
    --min-zoom "$MIN_ZOOM" \
    --max-zoom "$MAX_ZOOM" \
    --output-dir tiles \
    --delay 0.5 \
    --max-workers 2 \
    --source "$SOURCE"
else
  echo "ERROR: CITY not specified"
  exit 1
fi

mkdir -p "/Volumes/$CARD_NAME/maps/osm"
rm -rf "/Volumes/$CARD_NAME/maps/osm/"* 2>/dev/null || true
cp -R tiles/* "/Volumes/$CARD_NAME/maps/osm/"
rm -f "/Volumes/$CARD_NAME/maps/osm/metadata.json"

diskutil eject "/Volumes/$CARD_NAME"

echo "Done → insert card + reboot T-Deck"
EOF