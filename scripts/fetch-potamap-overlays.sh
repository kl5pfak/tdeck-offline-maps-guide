#!/usr/bin/env bash
# fetch-potamap-overlays.sh — Download GeoJSON overlay files for a potamap region.
#
# Usage:
#   scripts/fetch-potamap-overlays.sh <REGION_KEY> [TITLE_FILTER] [--out-dir DIR] [--dry-run] [--simplify PCT]
#
# Examples:
#   scripts/fetch-potamap-overlays.sh US-AK
#   scripts/fetch-potamap-overlays.sh US-AK 'Parks|Counties'
#   scripts/fetch-potamap-overlays.sh US-AK 'Parks' --out-dir /tmp/overlays/US-AK
#   scripts/fetch-potamap-overlays.sh US-AK 'Parks' --dry-run
#   scripts/fetch-potamap-overlays.sh US-AK 'Parks' --simplify 30

set -euo pipefail
IFS=$'\n\t'

LAYERDATA_URL="https://raw.githubusercontent.com/cwhelchel/potamap.ol/main/LayerData.js"
RAW_BASE_URL="https://raw.githubusercontent.com/cwhelchel/potamap.ol/main"

usage() {
  sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'
  exit 1
}

[[ $# -lt 1 ]] && usage

REGION_KEY="$1"
shift

# Second positional arg (if not a flag) is the title filter
TITLE_FILTER=""
if [[ $# -gt 0 && "${1}" != --* ]]; then
  TITLE_FILTER="$1"
  shift
fi

OUT_DIR="overlays/${REGION_KEY}"
DRY_RUN=false
SIMPLIFY_PCT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --out-dir)   OUT_DIR="$2";    shift 2 ;;
    --dry-run)   DRY_RUN=true;    shift   ;;
    --simplify)  SIMPLIFY_PCT="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; usage ;;
  esac
done

# Use Python to fetch and parse LayerData.js
PAIRS=$(python3 - "$REGION_KEY" "$TITLE_FILTER" "$LAYERDATA_URL" << 'EOF'
import sys, re, urllib.request

region_key   = sys.argv[1]
title_filter = sys.argv[2]   # may be empty
url          = sys.argv[3]

with urllib.request.urlopen(url) as r:
    data = r.read().decode()

pattern = r"""['"]{0,1}""" + re.escape(region_key) + r"""['"]{0,1}\s*:\s*\[(.*?)\]"""
m = re.search(pattern, data, re.DOTALL)
if not m:
    print(f"No layers found for region: {region_key}", file=sys.stderr)
    sys.exit(1)

block  = m.group(1)
titles = re.findall(r"""title\s*:\s*['"]([^'"]+)['"]""", block)
files  = re.findall(r"""file\s*:\s*['"]([^'"]+)['"]""", block)

for t, f in zip(titles, files):
    if title_filter:
        if not re.search(title_filter, t, re.IGNORECASE):
            continue
    print(f"{t}\t{f}")
EOF
)

if [[ -z "$PAIRS" ]]; then
  echo "No layers matched for region: $REGION_KEY (filter: '${TITLE_FILTER}')" >&2
  exit 1
fi

if ! $DRY_RUN; then
  mkdir -p "$OUT_DIR"
  echo "title\tfile\turl\toutput" > "${OUT_DIR}/manifest.tsv"
fi

while IFS=$'\t' read -r title rel_file; do
  # Build raw URL — files with a path separator are already relative to repo root
  if echo "$rel_file" | grep -q "/"; then
    raw_url="${RAW_BASE_URL}/${rel_file}"
  else
    raw_url="${RAW_BASE_URL}/data/${REGION_KEY}/${rel_file}"
  fi

  # Sanitize title to a safe filename
  safe_name=$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]/_/g' | sed 's/__*/_/g').geojson
  out_path="${OUT_DIR}/${safe_name}"

  echo "  [layer] $title"
  echo "          url:  $raw_url"
  echo "          dest: $out_path"

  if $DRY_RUN; then continue; fi

  if curl -fsSL "$raw_url" -o "$out_path" 2>/dev/null; then
    echo "          ✓ downloaded"
  else
    echo "          ✗ failed (skipping)" >&2
    continue
  fi

  if [[ -n "$SIMPLIFY_PCT" ]]; then
    if command -v mapshaper &>/dev/null; then
      mapshaper -i "$out_path" -simplify "${SIMPLIFY_PCT}%" -o force "$out_path" 2>/dev/null
      echo "          ✓ simplified to ${SIMPLIFY_PCT}%"
    else
      echo "          ! mapshaper not found, skipping simplification" >&2
    fi
  fi

  printf "%s\t%s\t%s\t%s\n" "$title" "$rel_file" "$raw_url" "$safe_name" >> "${OUT_DIR}/manifest.tsv"
done <<< "$PAIRS"

if ! $DRY_RUN; then
  echo ""
  echo "Overlays saved to: $OUT_DIR"
  echo "Manifest:          ${OUT_DIR}/manifest.tsv"
fi
