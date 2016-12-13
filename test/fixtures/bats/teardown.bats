LOG="$TMP/teardown.log"

teardown() {
  printf "$BATS_TEST_NAME\n" >> "$LOG"
}

@test "one" {
  true
}

@test "two" {
  false
}

@test "three" {
  true
}
