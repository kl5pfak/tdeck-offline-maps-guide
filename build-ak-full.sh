cat > build-ak-full.sh <<'EOF'
#!/bin/bash
set -euo pipefail

cd ~/tdeck-maps

CARD_NAME=$(ls /Volumes | grep -E "TDECK|NO NAME|UNTITLED" | head -n 1 || true)

if [ -z "$CARD_NAME" ]; then
  echo "ERROR: SD card not found"
  exit 1
fi

echo "Using SD card: $CARD_NAME"

rm -rf tiles_low tiles_local tiles_merged

echo "Building Alaska low-res base..."
python3 meshtastic_tiles.py \
  --coords \
  --north 72 \
  --south 51 \
  --east -130 \
  --west -180 \
  --min-zoom 4 \
  --max-zoom 7 \
  --output-dir tiles_low \
  --delay 0.5 \
  --max-workers 2 \
  --source terrain

echo "Building Fairbanks high-res..."
python3 meshtastic_tiles.py \
  --city "Fairbanks, Alaska" \
  --min-zoom 6 \
  --max-zoom 12 \
  --output-dir tiles_local \
  --delay 0.5 \
  --max-workers 2 \
  --source terrain

echo "Merging tiles..."
mkdir -p tiles_merged
cp -R tiles_low/* tiles_merged/
cp -R tiles_local/* tiles_merged/

mkdir -p "/Volumes/$CARD_NAME/maps/osm"
rm -rf "/Volumes/$CARD_NAME/maps/osm/"* 2>/dev/null || true
cp -R tiles_merged/* "/Volumes/$CARD_NAME/maps/osm/"
rm -f "/Volumes/$CARD_NAME/maps/osm/metadata.json"

diskutil eject "/Volumes/$CARD_NAME"

echo "Done → full Alaska + local detail loaded"
EOF