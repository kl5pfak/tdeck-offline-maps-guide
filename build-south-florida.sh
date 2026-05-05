#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CARD_TARGET="${1:-TDECK-FL}"
BASE_SOURCE="${2:-terrain}"

run_build() {
  local location="$1"
  local min_zoom="$2"
  local max_zoom="$3"

  "$SCRIPT_DIR/build-core.sh" "$location" "$min_zoom" "$max_zoom" "$BASE_SOURCE" "$CARD_TARGET"
}

run_build "South Florida" 4 7
run_build "Port Saint Lucie, Florida" 7 11
run_build "Miami, Florida" 7 12
run_build "Key Largo, Florida" 8 13
run_build "Key West, Florida" 8 13
