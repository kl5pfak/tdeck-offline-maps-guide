# T-Deck Offline Maps Guide

![T-Deck Map Working](screenshots/tdeck-map-working.jpg)
Simple guide to get offline maps working on the T-Deck.

## Quick Start

1. Clone tile generator:
   git clone https://github.com/JustDr00py/tdeck-maps~/tdeck-maps

2. Add your Thunderforest API key inside:
   meshtastic_tiles.py → get_tile_url()

3. Run:
   ./build.sh

4. Insert SD card → reboot → open Maps (MUI)

## 🧠 How this works

- Script downloads tiles → `tiles/`
- Files copied → `/maps/osm/` on SD card
- T-Deck reads files → displays map

The T-Deck does NOT download maps itself.

## 📁 Expected SD card layout

/maps/osm/
├── 4/
├── 5/
├── 6/
├── 7/
├── 8/
├── 9/
└── 10/

## Important

- Maps must be in: /maps/osm/
- Must include zoom levels: 4, 5, 6
- Public OSM tiles will fail (403 errors)

## Example

./build.sh "Fairbanks, Alaska"
./build.sh "Charleston, South Carolina" 4 10 terrain TDECK-AK

## Troubleshooting

## 🚨 If your map is blank

- Missing zoom 4–6 → rebuild with lower zoom
- Wrong folder → must be `/maps/osm/`
- Not in MUI → enable MUI
- Wrong region → zoom out first
- Blank map → missing low zoom tiles
- Only 1 folder → copy failed
