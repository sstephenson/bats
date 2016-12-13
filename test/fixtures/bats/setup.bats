LOG="$TMP/setup.log"

setup() {
  printf "$BATS_TEST_NAME\n" >> "$LOG"
}

@test "one" {
  [ "$(tail -n 1 "$LOG")" = "test_one" ]
}

@test "two" {
  [ "$(tail -n 1 "$LOG")" = "test_two" ]
}

@test "three" {
  [ "$(tail -n 1 "$LOG")" = "test_three" ]
}
