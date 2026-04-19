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

[[ $# -lt 1 ]] && usage

REGION_KEY="$1"
TITLES_ONLY=false
[[ "${2:-}" == "--titles-only" ]] && TITLES_ONLY=true

python3 - "$REGION_KEY" "$TITLES_ONLY" "$LAYERDATA_URL" << 'EOF'
import sys, re, urllib.request

region_key  = sys.argv[1]
titles_only = sys.argv[2] == "true"
url         = sys.argv[3]

with urllib.request.urlopen(url) as r:
    data = r.read().decode()

# Find the JS array block for this region
pattern = r"""['"]{0,1}""" + re.escape(region_key) + r"""['"]{0,1}\s*:\s*\[(.*?)\]"""
m = re.search(pattern, data, re.DOTALL)
if not m:
    print(f"No layers found for region: {region_key}", file=sys.stderr)
    sys.exit(1)

block  = m.group(1)
titles = re.findall(r"""title\s*:\s*['"]([^'"]+)['"]""", block)
files  = re.findall(r"""file\s*:\s*['"]([^'"]+)['"]""", block)

if not titles:
    print(f"No layers parsed for region: {region_key}", file=sys.stderr)
    sys.exit(1)

for t, f in zip(titles, files):
    if titles_only:
        print(t)
    else:
        print(f"{t:<40} {f}")
EOF
