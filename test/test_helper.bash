fixtures() {
  FIXTURE_ROOT="$BATS_TEST_DIRNAME/fixtures/$1"
  bats_trim_filename "$FIXTURE_ROOT" 'RELATIVE_FIXTURE_ROOT'
}

setup() {
  export TMP="$BATS_TEST_DIRNAME/tmp"
}

filter_control_sequences() {
  "$@" | sed $'s,\x1b\\[[0-9;]*[a-zA-Z],,g'
}

if ! command -v tput >/dev/null; then
  tput() {
    printf '1000\n'
  }
  export -f tput
fi

teardown() {
  [ -d "$TMP" ] && rm -f "$TMP"/*
}
