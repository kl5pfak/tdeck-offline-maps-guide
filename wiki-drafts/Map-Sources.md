# Map Sources

Available sources for `--source` (supported by `meshtastic_tiles.py`):

| Source | Type | Best for |
|---|---|---|
| `terrain` | Free | Topographic overview (default base) |
| `osm` | Free | Standard OpenStreetMap street map |
| `satellite` | Free | Aerial/satellite imagery |
| `usgs_topo` | Free (US only) | USGS topo detail, contour lines, public lands |
| `cycle` | Thunderforest key required | Bike routes, trails, road detail |

## USGS Topo notes

- Free, no API key required.
- US coverage only (contiguous US, Alaska, Hawaii).
- Tile URL: `https://basemap.nationalmap.gov/arcgis/rest/services/USGSTopo/MapServer/tile/{z}/{y}/{x}`
- Note the tile coordinate order is `{z}/{y}/{x}` (row before column), same as ArcGIS satellite source.
- Useful zoom range: 4–16. High detail available at zoom 15–16.
- Best for field use: shows contour lines, elevation, public land boundaries, hydrography.

## Thunderforest notes

- Only `cycle` is built into the current `meshtastic_tiles.py` source map.
- `outdoors`, `transport`, and other Thunderforest styles are not built in by default.
- To add additional styles, extend the `sources` dict in `get_tile_url()` using the same URL pattern as `cycle` and your API key.
