#!/usr/bin/env bats

FIXTURE_ROOT="$BATS_TEST_DIRNAME/fixtures"

@test "no arguments prints usage instructions" {
  run bats
  [ $status -eq 1 ]
  [ $(expr "$output" : "usage:") -ne 0 ]
}

@test "invalid filename prints an error" {
  run bats nonexistent
  [ $status -eq 1 ]
  [ $(expr "$output" : ".*does not exist") -ne 0 ]
}

@test "empty test file runs zero tests" {
  run bats "$FIXTURE_ROOT/empty.bats"
  [ $status -eq 0 ]
  [ $output = "1..0" ]
}

@test "one passing test" {
  run bats "$FIXTURE_ROOT/passing.bats"
  [ $status -eq 0 ]
  [ ${lines[0]} = "1..1" ]
  [ ${lines[1]} = "ok 1 a passing test" ]
}

@test "one failing test" {
  run bats "$FIXTURE_ROOT/failing.bats"
  [ $status -eq 1 ]
  [ ${lines[0]} = "1..1" ]
  [ ${lines[1]} = "not ok 1 a failing test" ]
}

@test "one failing and one passing test" {
  run bats "$FIXTURE_ROOT/failing_and_passing.bats"
  [ $status -eq 1 ]
  [ ${lines[0]} = "1..2" ]
  [ ${lines[1]} = "not ok 1 a failing test" ]
  [ ${lines[2]} = "ok 2 a passing test" ]
}
