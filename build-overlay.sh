#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ---------------------------------------------------------------------------
# build-overlay.sh
#
# Builds a two-layer raster tile set for the T-Deck:
#   - BASE layer   : a terrain/context source at low zoom (overview)
#   - OVERLAY layer: a user-specified source at high zoom (detail)
#
# Tiles are merged so the overlay source wins at its zoom levels.
# The result is written to the SD card at /maps/osm/.
#
# Available Thunderforest sources (requires API key):
#   terrain | cycle | transport | landscape | outdoors
#   spinal-map | pioneer | mobile-atlas | neighbourhood | atlas
#
# Usage:
#   ./build-overlay.sh <city> <overlay_source> [base_zoom_max=7]
#                      [overlay_zoom_min=8] [overlay_zoom_max=12]
#                      [base_source=terrain] [card_label_or_mount]
#
# Examples:
#   ./build-overlay.sh "Anchorage, Alaska" cycle
#   ./build-overlay.sh "Fairbanks, Alaska" outdoors 7 8 13
#   ./build-overlay.sh "Denver, Colorado"  transport 6 7 12 terrain TDECK-AK
# ---------------------------------------------------------------------------

usage() {
  cat <<USAGE
Usage:
  $0 <city> <overlay_source> [base_zoom_max=7] [overlay_zoom_min=8]
     [overlay_zoom_max=12] [base_source=terrain] [card_label_or_mount]

Overlay sources (Thunderforest):
  terrain | cycle | transport | landscape | outdoors |
  spinal-map | pioneer | mobile-atlas | neighbourhood | atlas

Environment:
  TDECK_MAPS_DIR   Path to tdeck-maps repo (default: ~/tdeck-maps)
USAGE
}

die() {
  echo "ERROR: $*" >&2
  exit 1
}

find_card_mount() {
  local requested_label="${1:-}"
  local roots=("/Volumes" "/media/${USER:-}" "/run/media/${USER:-}")
  local root found

  if [[ -n "$requested_label" ]]; then
    if [[ "$requested_label" == /* ]] && [[ -d "$requested_label" ]]; then
      printf '%s\n' "$requested_label"
      return 0
    fi
    for root in "${roots[@]}"; do
      if [[ -d "$root/$requested_label" ]]; then
        printf '%s\n' "$root/$requested_label"
        return 0
      fi
    done
    return 1
  fi

  for root in "${roots[@]}"; do
    [[ -d "$root" ]] || continue
    found=$(find "$root" -mindepth 1 -maxdepth 1 -type d \
      \( -iname '*tdeck*' -o -iname 'NO NAME' -o -iname 'UNTITLED' \) \
      | head -n 1 || true)
    if [[ -n "$found" ]]; then
      printf '%s\n' "$found"
      return 0
    fi
  done

  return 1
}

merge_tiles() {
  local from_dir="$1"
  local to_dir="$2"
  mkdir -p "$to_dir"
  # rsync --ignore-existing so base does not overwrite overlay zoom levels
  # that were already copied; call order is: overlay first, then base.
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --ignore-existing "$from_dir/" "$to_dir/"
  else
    cp -Rn "$from_dir/." "$to_dir/"
  fi
}

copy_to_card() {
  local from_dir="$1"
  local to_dir="$2"
  mkdir -p "$to_dir"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete "$from_dir/" "$to_dir/"
  else
    find "$to_dir" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +
    cp -R "$from_dir/." "$to_dir/"
  fi
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage; exit 0
fi

CITY="${1:-}"
OVERLAY_SOURCE="${2:-}"
BASE_ZOOM_MAX="${3:-7}"
OVERLAY_ZOOM_MIN="${4:-8}"
OVERLAY_ZOOM_MAX="${5:-12}"
BASE_SOURCE="${6:-terrain}"
CARD_NAME="${7:-}"
TDECK_MAPS_DIR="${TDECK_MAPS_DIR:-$HOME/tdeck-maps}"

[[ -n "$CITY" ]]           || { usage; die "city not specified"; }
[[ -n "$OVERLAY_SOURCE" ]] || { usage; die "overlay_source not specified"; }

[[ "$BASE_ZOOM_MAX"    =~ ^[0-9]+$ ]] || die "base_zoom_max must be a number"
[[ "$OVERLAY_ZOOM_MIN" =~ ^[0-9]+$ ]] || die "overlay_zoom_min must be a number"
[[ "$OVERLAY_ZOOM_MAX" =~ ^[0-9]+$ ]] || die "overlay_zoom_max must be a number"
(( OVERLAY_ZOOM_MIN <= OVERLAY_ZOOM_MAX )) || die "overlay_zoom_min must be <= overlay_zoom_max"

command -v python3 >/dev/null 2>&1     || die "Missing required command: python3"
[[ -d "$TDECK_MAPS_DIR" ]]             || die "tdeck-maps directory not found at: $TDECK_MAPS_DIR"

CARD_MOUNT=$(find_card_mount "$CARD_NAME" || true)
[[ -n "$CARD_MOUNT" ]] || die "No SD card mount found. Pass card label or mount path as arg 7."

echo "---------------------------------------------------"
echo "City         : $CITY"
echo "Base source  : $BASE_SOURCE  (zoom 4–${BASE_ZOOM_MAX})"
echo "Overlay      : $OVERLAY_SOURCE  (zoom ${OVERLAY_ZOOM_MIN}–${OVERLAY_ZOOM_MAX})"
echo "SD card      : $CARD_MOUNT"
echo "---------------------------------------------------"

cd "$TDECK_MAPS_DIR"
rm -rf tiles_base tiles_overlay tiles_merged

echo "Building base layer ($BASE_SOURCE, zoom 4–${BASE_ZOOM_MAX})..."
python3 meshtastic_tiles.py \
  --city "$CITY" \
  --min-zoom 4 \
  --max-zoom "$BASE_ZOOM_MAX" \
  --output-dir tiles_base \
  --delay 0.5 \
  --max-workers 2 \
  --source "$BASE_SOURCE"

echo "Building overlay layer ($OVERLAY_SOURCE, zoom ${OVERLAY_ZOOM_MIN}–${OVERLAY_ZOOM_MAX})..."
python3 meshtastic_tiles.py \
  --city "$CITY" \
  --min-zoom "$OVERLAY_ZOOM_MIN" \
  --max-zoom "$OVERLAY_ZOOM_MAX" \
  --output-dir tiles_overlay \
  --delay 0.5 \
  --max-workers 2 \
  --source "$OVERLAY_SOURCE"

echo "Merging layers (overlay takes priority at zoom ${OVERLAY_ZOOM_MIN}+)..."
mkdir -p tiles_merged
# Copy overlay first so its zoom dirs are the authoritative versions
cp -R tiles_overlay/. tiles_merged/
# Merge base without overwriting existing overlay zoom dirs
merge_tiles tiles_base tiles_merged

MAP_DIR="$CARD_MOUNT/maps/osm"
echo "Writing to SD card: $MAP_DIR"
copy_to_card tiles_merged "$MAP_DIR"
rm -f "$MAP_DIR/metadata.json"
sync

if command -v diskutil >/dev/null 2>&1 && [[ "$CARD_MOUNT" == /Volumes/* ]]; then
  diskutil eject "$CARD_MOUNT" || true
fi

echo "Done: $BASE_SOURCE base + $OVERLAY_SOURCE overlay written to card"
