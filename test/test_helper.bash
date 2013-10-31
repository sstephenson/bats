fixtures() {
  FIXTURE_ROOT="$BATS_TEST_DIRNAME/fixtures/$1"
  RELATIVE_FIXTURE_ROOT="$(bats_trim_filename "$FIXTURE_ROOT")"
}

setup() {
  export TMP="$BATS_TEST_DIRNAME/tmp"
}

filter_control_sequences() {
  "$@" | sed $'s,\x1b\\[[0-9;]*[a-zA-Z],,g'
}

teardown() {
  [ -d "$TMP" ] && rm -f "$TMP"/*
}
