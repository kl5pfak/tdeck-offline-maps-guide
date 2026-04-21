#!/usr/bin/env bats

setup() {
  REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
}

@test "all build scripts use bash shebang" {
  run grep -E '^#!/usr/bin/env bash$' "$REPO_ROOT/build-core.sh"
  [ "$status" -eq 0 ]

  run grep -E '^#!/usr/bin/env bash$' "$REPO_ROOT/build-alaska.sh"
  [ "$status" -eq 0 ]

  run grep -E '^#!/usr/bin/env bash$' "$REPO_ROOT/build-fairbanks.sh"
  [ "$status" -eq 0 ]

  run grep -E '^#!/usr/bin/env bash$' "$REPO_ROOT/build-ak-full.sh"
  [ "$status" -eq 0 ]

  run grep -E '^#!/usr/bin/env bash$' "$REPO_ROOT/build-charleston.sh"
  [ "$status" -eq 0 ]
}

@test "all build scripts pass bash syntax check" {
  run bash -n \
    "$REPO_ROOT/build-core.sh" \
    "$REPO_ROOT/build-alaska.sh" \
    "$REPO_ROOT/build-fairbanks.sh" \
    "$REPO_ROOT/build-ak-full.sh" \
    "$REPO_ROOT/build-charleston.sh"
  [ "$status" -eq 0 ]
}

@test "build-core help text is available" {
  run "$REPO_ROOT/build-core.sh" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}
