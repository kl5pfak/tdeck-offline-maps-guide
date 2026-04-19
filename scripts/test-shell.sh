#!/usr/bin/env bash
set -euo pipefail

if ! command -v bats >/dev/null 2>&1; then
  echo "ERROR: bats is not installed. Install it and rerun scripts/test-shell.sh" >&2
  exit 127
fi

bats tests/build_scripts.bats
