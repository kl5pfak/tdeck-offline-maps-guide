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
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete "$from_dir/" "$to_dir/"
  else
    find "$to_dir" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +
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
cp -R tiles_low/. tiles_merged/
cp -R tiles_local/. tiles_merged/

MAP_DIR="$CARD_MOUNT/maps/osm"
copy_tiles "tiles_merged" "$MAP_DIR"
rm -f "$MAP_DIR/metadata.json"
sync

if command -v diskutil >/dev/null 2>&1 && [[ "$CARD_MOUNT" == /Volumes/* ]]; then
  diskutil eject "$CARD_MOUNT" || true
fi

echo "Done: full Alaska and local detail loaded"