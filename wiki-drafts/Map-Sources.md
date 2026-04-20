# Map Sources

Available sources for `--source` (supported by `meshtastic_tiles.py`):

| Source | Type | Best for |
|---|---|---|
| `terrain` | Free | Topographic overview (default base) |
| `osm` | Free | Standard OpenStreetMap street map |
| `satellite` | Free | Aerial/satellite imagery |
| `cycle` | Thunderforest key required | Bike routes, trails, road detail |

## Thunderforest notes

- Only `cycle` is built into the current `meshtastic_tiles.py` source map.
- `outdoors`, `transport`, and other Thunderforest styles are not built in by default.
- To add additional styles, extend the `sources` dict in `get_tile_url()` using the same URL pattern as `cycle` and your API key.
