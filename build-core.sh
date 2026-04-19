#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<USAGE
Usage:
  $0 "City, State" [min_zoom=4] [max_zoom=10] [source=terrain] [card_label_or_mount]

Environment:
  TDECK_MAPS_DIR   Path to the tdeck-maps repo (default: ~/tdeck-maps)
USAGE
}

die() {
  echo "ERROR: $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

resolve_mount_from_label() {
  local label="$1"
  local roots=("/Volumes" "/media/${USER:-}" "/run/media/${USER:-}")
  local root

  if [[ "$label" == /* ]] && [[ -d "$label" ]]; then
    printf '%s\n' "$label"
    return 0
  fi

  for root in "${roots[@]}"; do
    if [[ -d "$root/$label" ]]; then
      printf '%s\n' "$root/$label"
      return 0
    fi
  done

  return 1
}

find_card_mount() {
  local requested_label="${1:-}"
  local roots=("/Volumes" "/media/${USER:-}" "/run/media/${USER:-}")
  local root found

  if [[ -n "$requested_label" ]]; then
    resolve_mount_from_label "$requested_label" && return 0
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

safe_clear_dir() {
  local dir="$1"
  mkdir -p "$dir"
  find "$dir" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +
}

copy_tiles() {
  local from_dir="$1"
  local to_dir="$2"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete "$from_dir/" "$to_dir/"
  else
    safe_clear_dir "$to_dir"
    cp -R "$from_dir/." "$to_dir/"
  fi
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

CITY="${1:-}"
MIN_ZOOM="${2:-4}"
MAX_ZOOM="${3:-10}"
SOURCE="${4:-terrain}"
CARD_NAME="${5:-}"
TDECK_MAPS_DIR="${TDECK_MAPS_DIR:-$HOME/tdeck-maps}"

[[ -n "$CITY" ]] || {
  usage
  die "CITY not specified"
}
[[ "$MIN_ZOOM" =~ ^[0-9]+$ ]] || die "min_zoom must be a number"
[[ "$MAX_ZOOM" =~ ^[0-9]+$ ]] || die "max_zoom must be a number"
(( MIN_ZOOM <= MAX_ZOOM )) || die "min_zoom must be <= max_zoom"

require_cmd python3
[[ -d "$TDECK_MAPS_DIR" ]] || die "tdeck-maps directory not found at: $TDECK_MAPS_DIR"

CARD_MOUNT=$(find_card_mount "$CARD_NAME" || true)
[[ -n "$CARD_MOUNT" ]] || die "No SD card mount found. Pass arg 5 as label or mount path."

echo "Using SD card mount: $CARD_MOUNT"
echo "Using tile source: $SOURCE"

cd "$TDECK_MAPS_DIR"
rm -rf tiles

echo "Building for city: $CITY"
python3 meshtastic_tiles.py \
  --city "$CITY" \
  --min-zoom "$MIN_ZOOM" \
  --max-zoom "$MAX_ZOOM" \
  --output-dir tiles \
  --delay 0.5 \
  --max-workers 2 \
  --source "$SOURCE"

MAP_DIR="$CARD_MOUNT/maps/osm"
mkdir -p "$MAP_DIR"
copy_tiles "tiles" "$MAP_DIR"
rm -f "$MAP_DIR/metadata.json"
sync

if command -v diskutil >/dev/null 2>&1 && [[ "$CARD_MOUNT" == /Volumes/* ]]; then
  diskutil eject "$CARD_MOUNT" || true
fi

echo "Done: insert card and reboot T-Deck"