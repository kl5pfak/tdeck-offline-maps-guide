# Overlay Maps (POTA / GeoJSON)

POTA/vector overlay rendering in-device is still pending.

You can already fetch and copy GeoJSON bundles to the SD card with the scripts below.

## List available layers

```bash
scripts/list-potamap-region-layers.sh US-AK
scripts/list-potamap-region-layers.sh US-AK --titles-only
```

## Download overlays

```bash
# Download selected Alaska overlays to overlays/US-AK
scripts/fetch-potamap-overlays.sh US-AK 'Parks|Counties'

# Preview only, do not download
scripts/fetch-potamap-overlays.sh US-AK 'Parks|Counties' --dry-run

# Simplify downloaded overlays (requires mapshaper)
scripts/fetch-potamap-overlays.sh US-AK 'Parks|Counties' --simplify 30
```

## Copy bundle to SD

```bash
scripts/copy-overlay-bundle.sh US-AK
scripts/copy-overlay-bundle.sh overlays/US-AK TDECK-AK
```

## List bundles on SD

```bash
scripts/list-sd-overlay-bundles.sh
scripts/list-sd-overlay-bundles.sh TDECK-AK
```

## Region workflows

Alaska:

```bash
scripts/list-potamap-region-layers.sh US-AK --titles-only
scripts/fetch-potamap-overlays.sh US-AK 'Parks|Counties'
scripts/copy-overlay-bundle.sh US-AK TDECK-AK
```

South Carolina:

```bash
scripts/list-potamap-region-layers.sh US-SC
scripts/fetch-potamap-overlays.sh US-SC 'Parks|Summits'
scripts/copy-overlay-bundle.sh US-SC TDECK-SC
```

Tip: keep bundles separated by region and copy only the region you are testing.
