# T-Deck Offline Maps Guide
<p align="center">
  <img alt="Platform" src="https://img.shields.io/badge/platform-T--Deck-blue">
  <img alt="Maps" src="https://img.shields.io/badge/maps-offline-green">
  <img alt="UI" src="https://img.shields.io/badge/ui-MUI-orange">
  <img alt="Region" src="https://img.shields.io/badge/tested-Alaska%20%2B%20Lower%2048-purple">
  <img alt="Status" src="https://img.shields.io/badge/status-working-brightgreen">
  <img alt="Changelog" src="https://img.shields.io/badge/changelog-v1.3.0-informational">
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

1. Clone this repository (the build scripts):

```bash
git clone https://github.com/kl5pfak/tdeck-offline-maps-guide ~/tdeck-maps-guide
cd ~/tdeck-maps-guide
```

2. Clone the tile generator and install its dependencies:

```bash
git clone https://github.com/JustDr00py/tdeck-maps ~/tdeck-maps
pip3 install requests Pillow
```

3. Configure map source access in `~/tdeck-maps/meshtastic_tiles.py` (`get_tile_url()`).

  You only need a Thunderforest API key if you use Thunderforest-backed sources (for example `cycle`, and any custom Thunderforest URLs you add).
  Default sources like `terrain`, `osm`, and `satellite` work without a Thunderforest key.

   Example (`cycle` with API key):

```python
def get_tile_url(self, x, y, zoom, source="osm"):
  thunderforest_key = "YOUR_THUNDERFOREST_API_KEY"
  sources = {
    "osm": f"https://tile.openstreetmap.org/{zoom}/{x}/{y}.png",
    "satellite": f"https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{zoom}/{y}/{x}",
    "terrain": f"https://tile.opentopomap.org/{zoom}/{x}/{y}.png",
    "cycle": f"https://tile.thunderforest.com/cycle/{zoom}/{x}/{y}.png?apikey={thunderforest_key}",
  }
  return sources.get(source, sources["osm"])
```

4. Run one of the build scripts:

**Quick & Easy (pre-configured regions):**
```bash
./build-anchorage.sh              # Downloads Anchorage area (zoom 4-10)
./build-ak.sh                     # Downloads Fairbanks area (zoom 4-10)
./build-charleston.sh             # Downloads Charleston area (zoom 4-10)
```

**Custom city (you specify location, zoom, source):**
```bash
# Format: build-core.sh "City, State" min_zoom max_zoom source [card_label]
./build-core.sh "Denver, Colorado" 4 10 terrain
./build-core.sh "Seattle, Washington" 4 12 satellite TDECK-AK
```

**Overlays (layered maps with Thunderforest source):**
```bash
# Format: build-overlay.sh "City, State" overlay_source [base_zoom_start] [base_zoom_end] [overlay_zoom_end] [base_source] [card_label]
./build-overlay.sh "Anchorage, Alaska" cycle
./build-overlay.sh "Fairbanks, Alaska" cycle 6 7 13 terrain TDECK-AK
```

**Vector overlays from potamap (GeoJSON for parks, peaks, etc.):**
```bash
scripts/list-potamap-region-layers.sh US-AK --titles-only
scripts/fetch-potamap-overlays.sh US-AK 'Parks|Counties'
scripts/copy-overlay-bundle.sh US-AK TDECK-AK
```

5. Insert SD card → reboot → open Maps in MUI

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

Map overlay (user-specified source layered over terrain base)
```bash
# terrain base (zoom 4–7) + cycle overlay (zoom 8–12)
./build-overlay.sh "Anchorage, Alaska" cycle

# terrain base + cycle overlay with custom zoom split
./build-overlay.sh "Fairbanks, Alaska" cycle 7 8 13

# terrain base + cycle overlay for a city, explicit card mount
./build-overlay.sh "Denver, Colorado" cycle 6 7 12 terrain TDECK-AK
```

Available sources for `--source` (supported by `meshtastic_tiles.py`):

| Source | Type | Best for |
|---|---|---|
| `terrain` | Free | Topographic overview (default base) |
| `osm` | Free | Standard OpenStreetMap street map |
| `satellite` | Free | Aerial/satellite imagery |
| `cycle` | Thunderforest key required | Bike routes, trails, road detail |

> **Note:** `outdoors`, `transport`, and other Thunderforest styles are not built into `meshtastic_tiles.py`. To add them, add entries to the `sources` dict in `get_tile_url()` following the `cycle` URL pattern in step 3 above.

Region overlays from potamap (GeoJSON)

Alaska overlay bundle workflow
```bash
# list layer titles/files for a region
scripts/list-potamap-region-layers.sh US-AK

# list only titles
scripts/list-potamap-region-layers.sh US-AK --titles-only

# download selected Alaska overlays to overlays/US-AK
scripts/fetch-potamap-overlays.sh US-AK 'Parks|Counties'

# preview only, do not download
scripts/fetch-potamap-overlays.sh US-AK 'Parks|Counties' --dry-run

# simplify downloaded overlays (requires mapshaper)
scripts/fetch-potamap-overlays.sh US-AK 'Parks|Counties' --simplify 30

# copy a bundle to SD card for end-user selection/storage
scripts/copy-overlay-bundle.sh US-AK
scripts/copy-overlay-bundle.sh overlays/US-AK TDECK-AK

# list overlay bundles currently on SD card
scripts/list-sd-overlay-bundles.sh
scripts/list-sd-overlay-bundles.sh TDECK-AK
```

South Carolina overlay bundle workflow
```bash
scripts/list-potamap-region-layers.sh US-SC
scripts/fetch-potamap-overlays.sh US-SC 'Parks|Summits'
scripts/copy-overlay-bundle.sh US-SC TDECK-SC
```

Tip: keep overlay bundles separated by region (US-AK, US-SC, etc.) and copy only the region you are actively testing.

## 🗺️ Version Guide

| Version | Status | Notes |
|---|---|---|
| v1.2.0 | Current | Core map builds, SD copy flow, shell checks, and raster overlays using supported sources (`terrain`, `osm`, `satellite`, `cycle`). |
| v1.3.0 (planned) | Pending | POTA/vector overlay integration in-device is still pending. Scripts can fetch/copy GeoJSON bundles, but MUI rendering/selection is not complete yet. |

POTA is currently a pending feature for end-user map display. Use raster tile workflows for reliable on-device map results today.

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
