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

if [[ $# -lt 1 ]]; then
  usage
fi

REGION_KEY="$1"
TITLE_FILTER="${2:-}"
# Strip leading -- from filter if accidentally passed as flag
[[ "$TITLE_FILTER" == --* ]] && TITLE_FILTER=""

OUT_DIR="overlays/${REGION_KEY}"
DRY_RUN=false
SIMPLIFY_PCT=""

shift; [[ $# -ge 1 && "$1" != --* ]] && { shift || true; }   # consumed filter above
while [[ $# -gt 0 ]]; do
  case "$1" in
    --out-dir)   OUT_DIR="$2"; shift 2 ;;
    --dry-run)   DRY_RUN=true; shift ;;
    --simplify)  SIMPLIFY_PCT="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; usage ;;
  esac
done

RAW=$(curl -fsSL "$LAYERDATA_URL")

REGION_BLOCK=$(echo "$RAW" | awk "/['\"]${REGION_KEY}['\"]/{found=1} found{print} found && /\]/{exit}")

if [[ -z "$REGION_BLOCK" ]]; then
  echo "No layers found for region: $REGION_KEY" >&2
  exit 1
fi

# Parse pairs
PAIRS=$(echo "$REGION_BLOCK" | awk '
  /title:/ { match($0, /title:[[:space:]]*['"'"'"]([^'"'"'"]+)['"'"'"]/, arr); title=arr[1] }
  /file:/  { match($0, /file:[[:space:]]*['"'"'"]([^'"'"'"]+)['"'"'"]/, arr);
              file=arr[1];
              if (title != "") { print title "\t" file; title="" }
            }
')

if [[ -z "$PAIRS" ]]; then
  echo "No layers parsed for region: $REGION_KEY" >&2
  exit 1
fi

if ! $DRY_RUN; then
  mkdir -p "$OUT_DIR"
fi

MANIFEST_FILE="${OUT_DIR}/manifest.tsv"
if ! $DRY_RUN; then
  echo -e "title\tfile\turl\toutput" > "$MANIFEST_FILE"
fi

while IFS=$'\t' read -r title rel_file; do
  # Skip if filter is set and title doesn't match
  if [[ -n "$TITLE_FILTER" ]] && ! echo "$title" | grep -qiE "$TITLE_FILTER"; then
    continue
  fi

  # Build raw URL — regional files live under data/<REGION>/, shared files under data/
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

  if $DRY_RUN; then
    continue
  fi

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

  echo -e "${title}\t${rel_file}\t${raw_url}\t${safe_name}" >> "$MANIFEST_FILE"
done <<< "$PAIRS"

if ! $DRY_RUN; then
  echo ""
  echo "Overlays saved to: $OUT_DIR"
  echo "Manifest:          $MANIFEST_FILE"
fi
