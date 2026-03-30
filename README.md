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

Generate and copy a working map set with:  ./build.sh 

##SD card structure
/maps/osm/4
/maps/osm/5
/maps/osm/6
/maps/osm/7
/maps/osm/8
/maps/osm/9
/maps/osm/10

Common problems

Blank map

Usually caused by missing low zoom tiles.

403 errors

Usually caused by downloading from public OpenStreetMap tile servers.

Maps not loading

Usually caused by wrong SD path. Use:

/maps/osm/

Examples
	•	Fairbanks example￼
	•	Charleston example￼
	•	Alaska regional builds￼

Notes

Use small regional builds first.
Do not start with a huge full-state high zoom build on a free tile API plan.

Credits
	•	Meshtastic
	•	LilyGO T-Deck
	•	tdeck-maps
