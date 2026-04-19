# T-Deck Offline Maps Guide
<p align="center">
  <img alt="Platform" src="https://img.shields.io/badge/platform-T--Deck-blue">
  <img alt="Maps" src="https://img.shields.io/badge/maps-offline-green">
  <img alt="UI" src="https://img.shields.io/badge/ui-MUI-orange">
  <img alt="Region" src="https://img.shields.io/badge/tested-Alaska%20%2B%20Lower%2048-purple">
  <img alt="Status" src="https://img.shields.io/badge/status-working-brightgreen">
  <img alt="Changelog" src="https://img.shields.io/badge/changelog-v1.2.0-informational">
</p>

<p align="center">
  Simple guide to get offline maps working on the LilyGO T-Deck using Meshtastic MUI and an SD card. Field-tested offline maps for Meshtastic T-Deck (Alaska + Lower 48)
</p>

---

## Example

<p align="center">
  <img src="screenshots/tdeck-map-working.jpeg" width="400">
</p>

---

## 🚀 Quick Start

1. Clone the tile generator:

```bash
git clone https://github.com/JustDr00py/tdeck-maps ~/tdeck-maps
```

2. Add your Thunderforest API key inside meshtastic_tiles.py in get_tile_url().

3. Run one of the build scripts:

```bash
./build-ak.sh
./build-anchorage.sh
./build-charleston.sh
./build-core.sh "City, State" 4 10 terrain
./build-ak-full.sh
```

4. Insert SD card → reboot → open Maps in MUI

## ✅ Shell Quality Checks

Run lint and tests before sharing changes:

```bash
scripts/lint-shell.sh
scripts/test-shell.sh
```

If tools are missing:

```bash
# Ubuntu/Debian
sudo apt-get update && sudo apt-get install -y shellcheck bats

# macOS (Homebrew)
brew install shellcheck bats-core
```

⸻

🧠 How this works

- The script downloads raster tiles into tiles/
- The files are copied to /maps/osm/ on the SD card
- The T-Deck reads those files and displays the map

The T-Deck does not download maps itself.


## 📁 The SD card must look exactly like this:

    /maps/osm/
    ├── 4/
    ├── 5/
    ├── 6/
    ├── 7/
    ├── 8/
    ├── 9/
    └── 10/

If this structure is wrong, maps will NOT load.

⚠️ Important

- Maps must be in /maps/osm/
- You must include zoom levels 4, 5, and 6
- Public OSM tiles will fail with 403 errors
- If the map is blank, zoom out first

⸻

🔧 Example Usage

Fairbanks
```bash
./build-ak.sh
```

Anchorage
```bash
./build-anchorage.sh
```

Charleston
```bash
./build-charleston.sh
```

Custom city with explicit card label or mount path
```bash
./build-core.sh "Charleston, South Carolina" 4 10 terrain TDECK-AK
./build-core.sh "Charleston, South Carolina" 4 10 terrain /Volumes/TDECK-AK
```

🚨 If your map is blank

- Missing zoom 4–6 → rebuild with lower zoom
- Wrong folder → must be /maps/osm/
- Not in MUI → enable MUI
- Wrong region → zoom out first
- Only 1 folder copied → copy failed

⸻

🏔 Alaska Strategy

Do not build full Alaska at high zoom on a free tile API.

Best setup:
- Low zoom (4–7) → statewide Alaska base
- High zoom (6–12) → Fairbanks / local detail

Use separate builds for:
- Local
- Regional corridor
- Statewide low-res base

⸻

💾 Backup your working map
cp -R /Volumes/TDECK*/maps ~/tdeck-map-backup

📜 Credits
- Meshtastic
- LilyGO T-Deck
- JustDr00py/tdeck-maps
- Community testing and debugging

---

## 📋 Changelog

See [CHANGELOG.md](CHANGELOG.md) for full version history.
