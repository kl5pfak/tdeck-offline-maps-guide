#!/usr/bin/env bash
set -euo pipefail

# Downloads default world fallback tiles at a chosen zoom level (default: 4)
# and merges them onto the SD card without overwriting existing tiles.
#
# Run this once after any build to ensure the T-Deck always has a
# world map at startup (default view is around 0°N/0°W = London area).
# Default zoom 4 is a practical startup overview for T-Deck.
#
# Usage:
#   ./build-world-base.sh [card_label=TDECK-AK] [source=osm] [zoom_level=4]

CARD_TARGET="${1:-TDECK-AK}"
SOURCE="${2:-osm}"
ZOOM_LEVEL="${3:-4}"

resolve_mount() {
  local label="$1"
  local roots=("/Volumes" "/media/${USER:-}" "/run/media/${USER:-}")
  if [[ "$label" == /* ]] && [[ -d "$label" ]]; then
    printf '%s\n' "$label"; return 0
  fi
  for root in "${roots[@]}"; do
    [[ -d "$root/$label" ]] && printf '%s\n' "$root/$label" && return 0
  done
  return 1
}

die() { echo "ERROR: $*" >&2; exit 1; }

[[ "$ZOOM_LEVEL" =~ ^[0-9]+$ ]] || die "zoom_level must be a number"

CARD_MOUNT=$(resolve_mount "$CARD_TARGET") || die "SD card not found: $CARD_TARGET"
MAP_DIR="$CARD_MOUNT/maps/osm"
mkdir -p "$MAP_DIR"

case "$SOURCE" in
  terrain)    BASE_URL="https://tile.opentopomap.org" ;;
  osm)        BASE_URL="https://tile.openstreetmap.org" ;;
  usgs_topo)  BASE_URL="https://basemap.nationalmap.gov/arcgis/rest/services/USGSTopo/MapServer/tile" ;;
  satellite)  BASE_URL="https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile" ;;
  *)          die "Unsupported source: $SOURCE (use terrain, osm, satellite, usgs_topo)" ;;
esac

tile_count=$(( (1 << ZOOM_LEVEL) * (1 << ZOOM_LEVEL) ))
echo "Downloading world fallback tiles (zoom ${ZOOM_LEVEL}, ${tile_count} tiles) from $SOURCE..."
echo "Destination: $MAP_DIR"

for z in "$ZOOM_LEVEL"; do
  max=$(( (1 << z) - 1 ))
  for x in $(seq 0 $max); do
    mkdir -p "$MAP_DIR/$z/$x"
    for y in $(seq 0 $max); do
      out="$MAP_DIR/$z/$x/$y.png"
      [[ -f "$out" ]] && continue   # skip already present tiles

      # ArcGIS / USGS use z/y/x order; others use z/x/y
      case "$SOURCE" in
        satellite|usgs_topo)
          url="$BASE_URL/$z/$y/$x" ;;
        *)
          url="$BASE_URL/$z/$x/$y.png" ;;
      esac

      curl -fsSL --retry 3 --retry-delay 1 "$url" -o "$out" || \
        echo "  WARN: failed $url"
    done
  done
done

rm -f "$MAP_DIR/metadata.json"
sync

echo "Done: world base tiles loaded onto $CARD_MOUNT"
