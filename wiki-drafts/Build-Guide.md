# Build Guide

## Build maps

Quick and easy (pre-configured regions):

```bash
./build-anchorage.sh              # Anchorage area (zoom 4-10)
./build-ak.sh                     # Fairbanks area (zoom 4-10)
./build-charleston.sh             # Charleston area (zoom 4-10)
```

Custom city:

```bash
# Format: build-core.sh "City, State" min_zoom max_zoom source [card_label]
./build-core.sh "Denver, Colorado" 4 10 terrain
./build-core.sh "Seattle, Washington" 4 12 satellite TDECK-AK
```

Overlay build:

```bash
# Format: build-overlay.sh "City, State" overlay_source [base_zoom_start] [base_zoom_end] [overlay_zoom_end] [base_source] [card_label]
./build-overlay.sh "Anchorage, Alaska" cycle
./build-overlay.sh "Fairbanks, Alaska" cycle 6 7 13 terrain TDECK-AK
```

## Example Usage

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
# terrain base (zoom 4-7) + cycle overlay (zoom 8-12)
./build-overlay.sh "Anchorage, Alaska" cycle

# terrain base + cycle overlay with custom zoom split
./build-overlay.sh "Fairbanks, Alaska" cycle 7 8 13

# terrain base + cycle overlay for a city, explicit card mount
./build-overlay.sh "Denver, Colorado" cycle 6 7 12 terrain TDECK-AK
```

Load maps:

Insert SD card -> reboot -> open Maps in MUI.
