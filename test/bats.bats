#!/usr/bin/env bats

FIXTURE_ROOT="$BATS_TEST_DIRNAME/fixtures"

@test "no arguments prints usage instructions" {
  run bats
  [[ $status -eq 1 ]]
  [[ $output =~ ^usage: ]]
}

@test "invalid filename prints an error" {
  run bats nonexistent
  [[ $status -eq 1 ]]
  [[ $output =~ does\ not\ exist ]]
}

@test "empty test file runs zero tests" {
  run bats "$FIXTURE_ROOT/empty.bats"
  [[ $status -eq 0 ]]
  [[ $output = "1..0" ]]
}
