# T-Deck Offline Maps Guide

Simple step-by-step guide to get offline maps working on the LilyGO T-Deck with Meshtastic MUI.

## Quick start

1. Clone `tdeck-maps`
2. Add your Thunderforest API key to `meshtastic_tiles.py`
3. Run `./build.sh`
4. Insert SD card into T-Deck
5. Open Maps in MUI

## What this solves

- Blank map screen
- Missing low zoom tiles
- 403 tile download errors
- Wrong SD card structure

## Requirements

- LilyGO T-Deck
- SD card
- Python3
- Thunderforest API key
- `tdeck-maps`

## Important

The T-Deck does not come with maps.  
You must provide your own tiles in:

`/maps/osm/`

You must include low zoom levels like `4`, `5`, and `6` or the map may appear blank.

## Easy workflow

Generate and copy a working map set with:

```bash
./build.sh 
