#!/usr/bin/env bash
# list-potamap-region-layers.sh — List available GeoJSON layer titles and files
# for a given potamap region key (e.g. US-AK, US-SC).
#
# Usage:
#   scripts/list-potamap-region-layers.sh <REGION_KEY> [--titles-only]
#
# Examples:
#   scripts/list-potamap-region-layers.sh US-AK
#   scripts/list-potamap-region-layers.sh US-AK --titles-only

set -euo pipefail
IFS=$'\n\t'

LAYERDATA_URL="https://raw.githubusercontent.com/cwhelchel/potamap.ol/main/LayerData.js"

usage() {
  sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'
  exit 1
}

if [[ $# -lt 1 ]]; then
  usage
fi

REGION_KEY="$1"
TITLES_ONLY=false
if [[ "${2:-}" == "--titles-only" ]]; then
  TITLES_ONLY=true
fi

# Fetch LayerData.js and extract layers for the given region
RAW=$(curl -fsSL "$LAYERDATA_URL")

# Find the block for the region and extract title/file pairs
REGION_BLOCK=$(echo "$RAW" | awk "/['\"]${REGION_KEY}['\"]/{found=1} found{print} found && /\]/{exit}")

if [[ -z "$REGION_BLOCK" ]]; then
  echo "No layers found for region: $REGION_KEY" >&2
  exit 1
fi

# Parse title and file from each layer entry
echo "$REGION_BLOCK" | awk '
  /title:/ { match($0, /title:[[:space:]]*['"'"'"]([^'"'"'"]+)['"'"'"]/, arr); title=arr[1] }
  /file:/  { match($0, /file:[[:space:]]*['"'"'"]([^'"'"'"]+)['"'"'"]/, arr);
              file=arr[1];
              if (title != "") {
                if (TITLES_ONLY == "true") print title
                else printf "%-40s %s\n", title, file
                title=""
              }
            }
' TITLES_ONLY="$TITLES_ONLY"
