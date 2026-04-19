#!/usr/bin/env bash
# copy-overlay-bundle.sh — Copy a local overlay bundle to the SD card.
#
# Usage:
#   scripts/copy-overlay-bundle.sh <BUNDLE_DIR_OR_KEY> [CARD_LABEL_OR_MOUNT]
#
# Examples:
#   scripts/copy-overlay-bundle.sh US-AK
#   scripts/copy-overlay-bundle.sh US-AK TDECK-AK
#   scripts/copy-overlay-bundle.sh overlays/US-AK TDECK-AK
#   scripts/copy-overlay-bundle.sh overlays/US-AK /Volumes/TDECK-AK

set -euo pipefail
IFS=$'\n\t'

usage() {
  sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'
  exit 1
}

[[ $# -lt 1 ]] && usage

BUNDLE_ARG="$1"
CARD_ARG="${2:-}"

# Resolve bundle directory
if [[ -d "$BUNDLE_ARG" ]]; then
  BUNDLE_DIR="$BUNDLE_ARG"
elif [[ -d "overlays/${BUNDLE_ARG}" ]]; then
  BUNDLE_DIR="overlays/${BUNDLE_ARG}"
else
  echo "Bundle not found: $BUNDLE_ARG (tried $BUNDLE_ARG and overlays/$BUNDLE_ARG)" >&2
  exit 1
fi

BUNDLE_NAME=$(basename "$BUNDLE_DIR")

# Find SD card mount
find_card_mount() {
  local label="$1"
  local roots=("/Volumes" "/media/${USER:-}" "/run/media/${USER:-}")
  for root in "${roots[@]}"; do
    [[ -d "${root}/${label}" ]] && { echo "${root}/${label}"; return; }
  done
  # Accept explicit full path
  [[ -d "$label" ]] && { echo "$label"; return; }
  echo "" 
}

if [[ -n "$CARD_ARG" ]]; then
  CARD_MOUNT=$(find_card_mount "$CARD_ARG")
  if [[ -z "$CARD_MOUNT" ]]; then
    echo "SD card not found: $CARD_ARG" >&2
    exit 1
  fi
else
  # Auto-detect: first mount containing /maps
  for root in /Volumes /media/${USER:-} /run/media/${USER:-}; do
    [[ -d "$root" ]] || continue
    for candidate in "$root"/*/; do
      [[ -d "${candidate}maps" ]] && { CARD_MOUNT="${candidate%/}"; break 2; }
    done
  done
  if [[ -z "${CARD_MOUNT:-}" ]]; then
    echo "No SD card with /maps found. Pass card label or mount path as second argument." >&2
    exit 1
  fi
fi

DEST="${CARD_MOUNT}/maps/overlays/${BUNDLE_NAME}"
mkdir -p "$DEST"

echo "Copying overlay bundle: $BUNDLE_DIR"
echo "Destination:            $DEST"

if command -v rsync &>/dev/null; then
  rsync -a --exclude='manifest.tsv' "$BUNDLE_DIR/" "$DEST/"
else
  cp -R "$BUNDLE_DIR"/. "$DEST/"
fi

echo "Done. Bundle installed at $DEST"
