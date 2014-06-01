fixtures() {
  FIXTURE_ROOT="$BATS_TEST_DIRNAME/fixtures/$1"
}

setup() {
  export TMP="$BATS_TEST_DIRNAME/tmp"
}

teardown() {
  # Safe guard, if $TMP might end up empty!
  [[ -d "$TMP" ]] || { echo "FATAL: \$TMP is not a directory in teardown."; exit 1; }
  rm -f "$TMP"/*
}
