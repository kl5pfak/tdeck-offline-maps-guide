# Alaska Strategy

Do not build full Alaska at high zoom on a free tile API.

Best setup:

- Low zoom (4-7) -> statewide Alaska base
- High zoom (6-12) -> Fairbanks or local detail

Use separate builds for:

- Local area
- Regional corridor
- Statewide low-res base

Example:

```bash
./build-ak.sh
./build-overlay.sh "Fairbanks, Alaska" cycle 7 8 13
```
