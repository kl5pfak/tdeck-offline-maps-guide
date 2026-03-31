#!/bin/bash
set -euo pipefail

CITY="${1:-Fairbanks, Alaska}"
MIN_ZOOM="${2:-4}"
MAX_ZOOM="${3:-10}"
SOURCE="${4:-terrain}"
CARD_NAME="${5:-TDECK-AK}"

cd ~/tdeck-maps

echo "Building map tiles for: $CITY"
echo "Zoom: $MIN_ZOOM to $MAX_ZOOM"
echo "Source: $SOURCE"
echo "Card: $CARD_NAME"

rm -rf tiles

python3 meshtastic_tiles.py \
  --city "$CITY" \
  --min-zoom "$MIN_ZOOM" \
  --max-zoom "$MAX_ZOOM" \
  --output-dir tiles \
  --delay 0.5 \
  --max-workers 2 \
  --source "$SOURCE"

mkdir -p "/Volumes/$CARD_NAME/maps/osm"
rm -rf "/Volumes/$CARD_NAME/maps/osm/"* 2>/dev/null || true
cp -R tiles/* "/Volumes/$CARD_NAME/maps/osm/"
rm -f "/Volumes/$CARD_NAME/maps/osm/metadata.json"

diskutil eject "/Volumes/$CARD_NAME"

echo "Done."
echo "Insert SD card → reboot → open Maps"
