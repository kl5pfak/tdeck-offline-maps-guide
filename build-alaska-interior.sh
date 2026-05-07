#!/usr/bin/env bash
set -euo pipefail

# Alaska Interior build with statewide navigation coverage.
# Uses usgs_topo by default for high-detail contour/topo maps.
# Includes a low-zoom Alaska base so it's easier to find interior tiles.
#
# Usage:
#   ./build-alaska-interior.sh [card_label=TDECK-AK] [source=usgs_topo]
#
# Approximate tile counts per run:
#   Alaska     zoom 3-8   ~400 tiles
#   Fairbanks  zoom 4-11  ~450 tiles
#   Galena     zoom 7-11  ~180 tiles
#   Delta Jct  zoom 7-11  ~180 tiles
#   Tok        zoom 7-11  ~180 tiles

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CARD_TARGET="${1:-TDECK-AK}"
BASE_SOURCE="${2:-usgs_topo}"

run_build() {
  local location="$1"
  local min_zoom="$2"
  local max_zoom="$3"

  "$SCRIPT_DIR/build-core.sh" "$location" "$min_zoom" "$max_zoom" "$BASE_SOURCE" "$CARD_TARGET"
}

run_build "Alaska"                  3 8
run_build "Fairbanks, Alaska"       4 11
run_build "Galena, Alaska"          7 11
run_build "Delta Junction, Alaska"  7 11
run_build "Tok, Alaska"             7 11
