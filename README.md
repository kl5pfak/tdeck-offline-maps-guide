cat > README.md <<'EOF'
# T-Deck Offline Maps Guide

Simple guide to get offline maps working on the T-Deck.

## Quick Start

1. Clone tile generator:
   git clone https://github.com/JustDr00py/tdeck-maps~/tdeck-maps

2. Add your Thunderforest API key inside:
   meshtastic_tiles.py → get_tile_url()

3. Run:
   ./build.sh

4. Insert SD card → reboot → open Maps (MUI)

## Important

- Maps must be in: /maps/osm/
- Must include zoom levels: 4, 5, 6
- Public OSM tiles will fail (403 errors)

## Example

./build.sh "Fairbanks, Alaska"
./build.sh "Charleston, South Carolina" 4 10 terrain TDECK-AK

## Troubleshooting

Blank map:
→ missing low zoom tiles

No maps:
→ wrong SD path

Only 1 folder:
→ copy failed
EOF

