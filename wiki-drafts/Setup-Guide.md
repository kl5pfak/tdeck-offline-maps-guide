# Setup Guide

## 1. Clone this repository

```bash
git clone https://github.com/kl5pfak/tdeck-offline-maps-guide ~/tdeck-maps-guide
cd ~/tdeck-maps-guide
```

## 2. Clone the tile generator and install dependencies

```bash
git clone https://github.com/JustDr00py/tdeck-maps ~/tdeck-maps
pip3 install requests Pillow
```

## 3. Configure map sources (optional)

Edit `~/tdeck-maps/meshtastic_tiles.py` in `get_tile_url()`.

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
