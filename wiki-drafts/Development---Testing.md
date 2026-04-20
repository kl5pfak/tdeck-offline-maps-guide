# Development / Testing

## Shell Quality Checks

Run lint and tests before sharing changes:

```bash
scripts/lint-shell.sh
scripts/test-shell.sh
```

If tools are missing:

```bash
# Ubuntu/Debian
sudo apt-get update && sudo apt-get install -y shellcheck bats

# macOS (Homebrew)
brew install shellcheck bats-core
```
