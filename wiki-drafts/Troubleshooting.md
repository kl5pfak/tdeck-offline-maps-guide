# Troubleshooting

- Missing zoom 4-6 -> rebuild with lower zoom
- Wrong folder -> must be `/maps/osm/`
- Not in MUI -> enable MUI
- Wrong region -> zoom out first
- Only one folder copied -> copy failed

## Common debug checks

```bash
# Confirm scripts exist and are executable
ls -l build-*.sh scripts/*.sh

# Check where your SD is mounted (macOS)
ls /Volumes

# Inspect SD map folders
ls -la /Volumes/TDECK-AK/maps/osm
```
