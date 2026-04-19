#!/usr/bin/env bash
# list-sd-overlay-bundles.sh — List overlay bundles currently on the SD card.
#
# Usage:
#   scripts/list-sd-overlay-bundles.sh [CARD_LABEL_OR_MOUNT]
#
# Examples:
#   scripts/list-sd-overlay-bundles.sh
#   scripts/list-sd-overlay-bundles.sh TDECK-AK

set -euo pipefail
IFS=$'\n\t'

usage() {
  sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'
  exit 1
}

CARD_ARG="${1:-}"

find_card_mount() {
  local label="$1"
  local roots=("/Volumes" "/media/${USER:-}" "/run/media/${USER:-}")
  for root in "${roots[@]}"; do
    [[ -d "${root}/${label}" ]] && { echo "${root}/${label}"; return; }
  done
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
  for root in /Volumes /media/${USER:-} /run/media/${USER:-}; do
    [[ -d "$root" ]] || continue
    for candidate in "$root"/*/; do
      [[ -d "${candidate}maps" ]] && { CARD_MOUNT="${candidate%/}"; break 2; }
    done
  done
  if [[ -z "${CARD_MOUNT:-}" ]]; then
    echo "No SD card with /maps found." >&2
    exit 1
  fi
fi

OVERLAYS_DIR="${CARD_MOUNT}/maps/overlays"

if [[ ! -d "$OVERLAYS_DIR" ]]; then
  echo "No overlays directory found on card: $OVERLAYS_DIR"
  exit 0
fi

printf "%-30s  %6s  %s\n" "BUNDLE" "FILES" "SIZE"
printf "%-30s  %6s  %s\n" "------" "-----" "----"

for bundle_dir in "$OVERLAYS_DIR"/*/; do
  [[ -d "$bundle_dir" ]] || continue
  name=$(basename "$bundle_dir")
  count=$(find "$bundle_dir" -maxdepth 1 -name "*.geojson" | wc -l | tr -d ' ')
  size=$(du -sh "$bundle_dir" 2>/dev/null | awk '{print $1}')
  printf "%-30s  %6s  %s\n" "$name" "$count" "$size"
done
