#!/usr/bin/env bash
set -euo pipefail

if ! command -v shellcheck >/dev/null 2>&1; then
  echo "ERROR: shellcheck is not installed. Install it and rerun scripts/lint-shell.sh" >&2
  exit 127
fi

shellcheck \
  build-core.sh \
  build-ak.sh \
  build-ak-full.sh \
  build-charleston.sh \
  build-anchorage.sh
