#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CARD_TARGET="${1:-TDECK-AK}"
BASE_SOURCE="${2:-terrain}"

run_build() {
  local location="$1"
  local min_zoom="$2"
  local max_zoom="$3"

  "$SCRIPT_DIR/build-core.sh" "$location" "$min_zoom" "$max_zoom" "$BASE_SOURCE" "$CARD_TARGET"
}

run_build "Alaska" 4 7
run_build "Fairbanks, Alaska" 6 12
run_build "Delta Junction, Alaska" 7 11
run_build "Tok, Alaska" 8 13