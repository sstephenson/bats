#!/usr/bin/env bats

FIXTURE_ROOT="$BATS_TEST_DIRNAME/fixtures"

@test "running 'bats' with no arguments prints usage instructions" {
  run bats
  [[ $status -eq 1 ]]
  [[ $output =~ ^usage: ]]
}

@test "running 'bats' with an invalid filename prints an error" {
  run bats nonexistent
  [[ $status -eq 1 ]]
  [[ $output =~ does\ not\ exist ]]
}

@test "running 'bats' with an empty test file runs zero tests" {
  run bats "$FIXTURE_ROOT/empty.bats"
  [[ $status -eq 0 ]]
  [[ $output = "1..0" ]]
}
