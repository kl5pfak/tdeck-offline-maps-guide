#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<USAGE
Usage:
  $0 --setup-thunderforest
  $0 "City, State" [min_zoom=4] [max_zoom=10] [source=terrain] [card_label_or_mount]

Environment:
  TDECK_MAPS_DIR          Path to the tdeck-maps repo (default: ~/tdeck-maps)
  THUNDERFOREST_API_KEY   API key used for Thunderforest-backed sources
USAGE
}

die() {
  echo "ERROR: $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

thunderforest_source() {
  case "$1" in
    cycle|transport|landscape|outdoors|spinal-map|pioneer|mobile-atlas|neighbourhood|atlas)
      return 0
      ;;
  esac
  return 1
}

load_thunderforest_key() {
  if [[ -z "${THUNDERFOREST_API_KEY:-}" ]] && [[ -f "$THUNDERFOREST_ENV_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$THUNDERFOREST_ENV_FILE"
  fi
}

prompt_thunderforest_key() {
  local force_prompt="${1:-false}"
  local requested_source="${2:-}"
  load_thunderforest_key

  if [[ -n "${THUNDERFOREST_API_KEY:-}" ]] && [[ "$force_prompt" != "true" ]]; then
    return 0
  fi

  [[ -t 0 ]] || die "THUNDERFOREST_API_KEY not set and no interactive terminal for prompt"

  if [[ "$force_prompt" != "true" ]]; then
    local setup_choice
    printf "THUNDERFOREST_API_KEY is not set. Add it now? [Yes/No]: "
    read -r setup_choice
    case "${setup_choice,,}" in
      yes|y)
        ;;
      no|n|"")
        if [[ -n "$requested_source" ]]; then
          die "THUNDERFOREST_API_KEY is required for source '$requested_source'. Set it in env or run '$0 --setup-thunderforest'."
        fi
        die "THUNDERFOREST_API_KEY is required. Set it in env or run '$0 --setup-thunderforest'."
        ;;
      *)
        die "Please answer Yes or No."
        ;;
    esac
  fi

  local api_key
  printf "Enter Thunderforest API key: "
  read -r -s api_key
  echo
  [[ -n "$api_key" ]] || die "Thunderforest API key cannot be empty"
  export THUNDERFOREST_API_KEY="$api_key"

  printf "Save key for future runs at %s? [Y/n]: " "$THUNDERFOREST_ENV_FILE"
  local save_choice
  read -r save_choice
  if [[ -z "$save_choice" || "$save_choice" =~ ^[Yy]$ ]]; then
    mkdir -p "$(dirname "$THUNDERFOREST_ENV_FILE")"
    umask 077
    printf 'export THUNDERFOREST_API_KEY=%q\n' "$THUNDERFOREST_API_KEY" > "$THUNDERFOREST_ENV_FILE"
    echo "Saved Thunderforest API key."
  fi
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
  # Merge tiles - no --delete so multi-step builds accumulate correctly
  if command -v rsync >/dev/null 2>&1; then
    rsync -a "$from_dir/" "$to_dir/"
  else
    cp -R "$from_dir/." "$to_dir/"
  fi
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ "${1:-}" == "--setup-thunderforest" ]]; then
  THUNDERFOREST_ENV_FILE="${THUNDERFOREST_ENV_FILE:-$HOME/.config/tdeck-maps/thunderforest.env}"
  prompt_thunderforest_key true
  echo "Thunderforest setup complete."
  exit 0
fi

CITY="${1:-}"
MIN_ZOOM="${2:-4}"
MAX_ZOOM="${3:-10}"
SOURCE="${4:-terrain}"
CARD_NAME="${5:-}"
TDECK_MAPS_DIR="${TDECK_MAPS_DIR:-$HOME/tdeck-maps}"
THUNDERFOREST_ENV_FILE="${THUNDERFOREST_ENV_FILE:-$HOME/.config/tdeck-maps/thunderforest.env}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

if thunderforest_source "$SOURCE"; then
  prompt_thunderforest_key false "$SOURCE"
fi

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

# Ensure the default zoom-4 world fallback map is present.
WORLD_BASE_MARKER="$MAP_DIR/.world-base-osm-z4.done"
WORLD_BASE_SENTINEL="$MAP_DIR/4/0/0.png"
if [[ -f "$SCRIPT_DIR/build-world-base.sh" ]]; then
  if [[ -f "$WORLD_BASE_MARKER" ]] && [[ -f "$WORLD_BASE_SENTINEL" ]]; then
    echo "World fallback tiles already present (zoom 4); skipping rebuild"
  else
    bash "$SCRIPT_DIR/build-world-base.sh" "$CARD_MOUNT" osm 4
    if [[ -f "$WORLD_BASE_SENTINEL" ]]; then
      : > "$WORLD_BASE_MARKER"
    fi
  fi
else
  echo "Warning: build-world-base.sh not found, skipping world fallback tiles"
fi

rm -f "$MAP_DIR/metadata.json"
sync

if command -v diskutil >/dev/null 2>&1 && [[ "$CARD_MOUNT" == /Volumes/* ]]; then
  diskutil eject "$CARD_MOUNT" || true
fi

echo "Done: insert card and reboot T-Deck"