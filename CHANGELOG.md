# Changelog

All notable changes to this project will be documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [1.3.1] - 2026-04-20

### Changed
- README was trimmed to a quick-start format focused on first-run success
- README now links to wiki documentation sections instead of embedding all deep-reference content
- Section formatting in README was cleaned up for better GitHub rendering

### Added
- `wiki-drafts/` pages added for manual wiki publishing:
	- `Home.md`
	- `Setup-Guide.md`
	- `Build-Guide.md`
	- `SD-Card-Setup.md`
	- `Overlay-Maps-(POTA---GeoJSON).md`
	- `Map-Sources.md`
	- `Troubleshooting.md`
	- `Alaska-Strategy.md`
	- `Development---Testing.md`
- README "Full Documentation" links for wiki navigation

### Notes
- POTA/vector overlay rendering in-device remains a pending feature

---

## [1.3.0] - 2026-04-19

### Added
- `build-overlay.sh` added to repository for layered raster tile builds
- Potamap helper scripts added:
	- `scripts/list-potamap-region-layers.sh`
	- `scripts/fetch-potamap-overlays.sh`
	- `scripts/copy-overlay-bundle.sh`
	- `scripts/list-sd-overlay-bundles.sh`
- README version guide clarifying current support status and planned features

### Changed
- Potamap parsing updated to use Python in helper scripts for macOS compatibility
- README corrected to list only currently supported `meshtastic_tiles.py` sources (`terrain`, `osm`, `satellite`, `cycle`)

### Notes
- POTA/vector overlay rendering in-device remains a pending feature

---

## [1.2.0] - 2026-04-19

### Added
- `build-anchorage.sh` — dedicated build script for Anchorage, Alaska (zoom 4–12, terrain)
- Shell test suite in `tests/build_scripts.bats` using Bats
- Shell lint runner `scripts/lint-shell.sh` using ShellCheck
- Shell test runner `scripts/test-shell.sh`
- README section documenting how to install and run quality checks

---

## [1.1.0] - 2026-04-19

### Added
- Cross-platform SD card mount detection (macOS `/Volumes`, Linux `/media`, `/run/media`)
- Support for passing an explicit card mount path or label as an argument
- `--help` / `-h` flag support in `build-core.sh`
- Argument validation in `build-core.sh` (zoom range, numeric checks)
- Dependency check for `python3` and `TDECK_MAPS_DIR` before running tiles script
- `rsync` support for tile copy with fallback to `cp` when rsync is unavailable
- `sync` call after tile copy to flush writes before ejection
- `TDECK_MAPS_DIR` environment variable override for custom repo paths
- `IFS=$'\n\t'` word-splitting protection in `build-core.sh` and `build-ak-full.sh`

### Changed
- `build-ak.sh` and `build-charleston.sh` use `SCRIPT_DIR` resolution so they work from any working directory
- Eject logic in `build-core.sh` and `build-ak-full.sh` is now conditional — only runs on macOS with `diskutil`
- Tile clearing now uses `find -exec rm` instead of glob expansion to avoid silent no-ops on empty dirs
- `cp -R tiles/*` replaced with `cp -R tiles/.` to avoid glob failures on hidden files

### Fixed
- `build-charleston.sh` had a trailing space in its filename — renamed to `build-charleston.sh`
- All scripts had heredoc/template artifacts (`cat > file <<'EOF'`) making them non-executable — removed
- `build-core.sh` had a leading `#` comment before the shebang — fixed

---

## [1.0.0] - 2026-03-31

### Added
- Initial release
- `build-core.sh` — parameterized tile builder using `meshtastic_tiles.py`
- `build-ak.sh` — Fairbanks, Alaska build wrapper (zoom 4–12)
- `build-ak-full.sh` — full Alaska statewide low-res + Fairbanks high-res merged build
- `build-charleston.sh` — Charleston, South Carolina build wrapper (zoom 4–10)
- `README.md` with Quick Start, SD card layout, troubleshooting, and Alaska strategy guide
- Screenshots directory
