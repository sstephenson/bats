#!/usr/bin/env bats

FIXTURE_ROOT="$BATS_TEST_DIRNAME/fixtures"
export TMP="$BATS_TEST_DIRNAME/tmp"

teardown() {
  rm -f "$TMP"/*
}

@test "no arguments prints usage instructions" {
  run bats
  [ $status -eq 1 ]
  [ $(expr "${lines[1]}" : "usage:") -ne 0 ]
}

@test "-v and --version print version number" {
  run bats -v
  [ $status -eq 0 ]
  [ $(expr "$output" : "Bats [0-9][0-9.]*") -ne 0 ]
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

@test "test environments are isolated" {
  run bats "$FIXTURE_ROOT/environment.bats"
  [ $status -eq 0 ]
}

@test "setup is run once before each test" {
  rm -f "$TMP/setup.log"
  run bats "$FIXTURE_ROOT/setup.bats"
  [ $status -eq 0 ]
  run cat "$TMP/setup.log"
  [ ${#lines[@]} -eq 3 ]
}

@test "teardown is run once after each test, even if it fails" {
  rm -f "$TMP/teardown.log"
  run bats "$FIXTURE_ROOT/teardown.bats"
  [ $status -eq 1 ]
  run cat "$TMP/teardown.log"
  [ ${#lines[@]} -eq 3 ]
}

@test "load sources scripts relative to the current test file" {
  run bats "$FIXTURE_ROOT/load.bats"
  [ $status -eq 0 ]
}

@test "output is discarded for passing tests and printed for failing tests" {
  run bats "$FIXTURE_ROOT/output.bats"
  [ $status -eq 1 ]
  [ "${lines[4]}" = "    failure stdout 1" ]
  [ "${lines[5]}" = "    failure stdout 2" ]
  [ "${lines[7]}" = "    failure stderr" ]
}

@test "-c prints the number of tests" {
  run bats -c "$FIXTURE_ROOT/empty.bats"
  [ $status -eq 0 ]
  [ "$output" = "0" ]

  run bats -c "$FIXTURE_ROOT/output.bats"
  [ $status -eq 0 ]
  [ "$output" = "4" ]
}
