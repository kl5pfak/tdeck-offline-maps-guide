#!/usr/bin/env bash
set -euo pipefail

# Alaska Interior — focused build for Fairbanks, Galena, Delta Junction, Tok
# Uses usgs_topo by default for high-detail contour/topo maps.
# Keeps zoom capped per city to control tile count and SD card space.
#
# Usage:
#   ./build-alaska-interior.sh [card_label=TDECK-AK] [source=usgs_topo]
#
# Approximate tile counts per run:
#   Fairbanks  zoom 4-10  ~300 tiles
#   Galena     zoom 7-10  ~120 tiles
#   Delta Jct  zoom 7-10  ~120 tiles
#   Tok        zoom 7-10  ~120 tiles

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CARD_TARGET="${1:-TDECK-AK}"
BASE_SOURCE="${2:-usgs_topo}"

run_build() {
  local location="$1"
  local min_zoom="$2"
  local max_zoom="$3"

  "$SCRIPT_DIR/build-core.sh" "$location" "$min_zoom" "$max_zoom" "$BASE_SOURCE" "$CARD_TARGET"
}

run_build "Fairbanks, Alaska"       4 10
run_build "Galena, Alaska"          7 10
run_build "Delta Junction, Alaska"  7 10
run_build "Tok, Alaska"             7 10
