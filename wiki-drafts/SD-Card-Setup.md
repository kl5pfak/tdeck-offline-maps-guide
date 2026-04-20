# SD Card Setup

The SD card must look exactly like this:

```text
/maps/osm/
├── 4/
├── 5/
├── 6/
├── 7/
├── 8/
├── 9/
└── 10/
```

If this structure is wrong, maps will not load.

## Important

- Maps must be in `/maps/osm/`
- You must include zoom levels 4, 5, and 6
- Public OSM tiles may return 403 errors
- If the map is blank, zoom out first
