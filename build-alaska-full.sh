#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

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

copy_tiles() {
  local from_dir="$1"
  local to_dir="$2"
  mkdir -p "$to_dir"
  # Merge - no --delete so world base and other regions are preserved
  if command -v rsync >/dev/null 2>&1; then
    rsync -a "$from_dir/" "$to_dir/"
  else
    cp -R "$from_dir/." "$to_dir/"
  fi
}

CARD_NAME="${1:-}"
TDECK_MAPS_DIR="${TDECK_MAPS_DIR:-$HOME/tdeck-maps}"

command -v python3 >/dev/null 2>&1 || die "Missing required command: python3"
[[ -d "$TDECK_MAPS_DIR" ]] || die "tdeck-maps directory not found at: $TDECK_MAPS_DIR"

CARD_MOUNT=$(find_card_mount "$CARD_NAME" || true)
[[ -n "$CARD_MOUNT" ]] || die "No SD card mount found. Pass card label or mount path as arg 1."

echo "Using SD card mount: $CARD_MOUNT"
cd "$TDECK_MAPS_DIR"
rm -rf tiles_low tiles_local tiles_merged

build_region() {
  local label="$1"; shift
  echo "Building $label..."
  python3 meshtastic_tiles.py "$@" \
    --output-dir tiles_region \
    --delay 0.5 \
    --max-workers 2 \
    --source terrain
  copy_tiles "tiles_region" "$MAP_DIR"
  rm -rf tiles_region
}

MAP_DIR="$CARD_MOUNT/maps/osm"
mkdir -p "$MAP_DIR"
rm -rf tiles_region

# Statewide Alaska base — zoom 3-8 covers full state at startup
build_region "Alaska statewide" \
  --coords \
  --north 72 --south 51 --east -130 --west -180 \
  --min-zoom 3 --max-zoom 8

# Interior cities — zoom 6-12 detail
build_region "Fairbanks" --city "Fairbanks, Alaska" --min-zoom 6 --max-zoom 12
build_region "Galena" --city "Galena, Alaska" --min-zoom 7 --max-zoom 11
build_region "Delta Junction" --city "Delta Junction, Alaska" --min-zoom 7 --max-zoom 11
build_region "Tok" --city "Tok, Alaska" --min-zoom 7 --max-zoom 11

# Southcentral
build_region "Anchorage" --city "Anchorage, Alaska" --min-zoom 6 --max-zoom 12
build_region "Palmer" --city "Palmer, Alaska" --min-zoom 7 --max-zoom 11
build_region "Wasilla" --city "Wasilla, Alaska" --min-zoom 7 --max-zoom 11

# Western
build_region "Nome" --city "Nome, Alaska" --min-zoom 7 --max-zoom 11
build_region "Bethel" --city "Bethel, Alaska" --min-zoom 7 --max-zoom 11

# World base tiles — ensures T-Deck renders at startup (0°N/0°W default view)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/build-world-base.sh" ]]; then
  echo "Adding world base tiles (zoom 4)..."
  bash "$SCRIPT_DIR/build-world-base.sh" "$CARD_MOUNT" osm 4
else
  echo "Warning: build-world-base.sh not found, skipping world base tiles"
fi

rm -f "$MAP_DIR/metadata.json"
sync

if command -v diskutil >/dev/null 2>&1 && [[ "$CARD_MOUNT" == /Volumes/* ]]; then
  diskutil eject "$CARD_MOUNT" || true
fi

echo "Done: full Alaska and local detail loaded"