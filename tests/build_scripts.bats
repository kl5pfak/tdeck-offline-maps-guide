#!/usr/bin/env bats

setup() {
  REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
}

@test "all build scripts use bash shebang" {
  local script
  local scripts=("$REPO_ROOT"/build-*.sh)

  for script in "${scripts[@]}"; do
    run grep -E '^#!/usr/bin/env bash$' "$script"
    [ "$status" -eq 0 ]
  done
}

@test "all build scripts pass bash syntax check" {
  run bash -n "$REPO_ROOT"/build-*.sh
  [ "$status" -eq 0 ]
}

@test "build-core help text is available" {
  run "$REPO_ROOT/build-core.sh" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}
