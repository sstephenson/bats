#!/usr/bin/env bats

load test_helper
fixtures suite

@test "running a suite with no test files" {
  run bats "$FIXTURE_ROOT/empty"
  [ $status -eq 0 ]
  [ $output = "1..0" ]
}

@test "running a suite with one test file" {
  run bats "$FIXTURE_ROOT/single"
  [ $status -eq 0 ]
  [ ${lines[0]} = "1..1" ]
  [ ${lines[1]} = "ok 1 a passing test" ]
}

@test "counting tests in a suite" {
  run bats -c "$FIXTURE_ROOT/single"
  [ $status -eq 0 ]
  [ $output -eq 1 ]

  run bats -c "$FIXTURE_ROOT/multiple"
  [ $status -eq 0 ]
  [ $output -eq 3 ]
}

@test "aggregated output of multiple tests in a suite" {
  run bats "$FIXTURE_ROOT/multiple"
  [ $status -eq 0 ]
  [ ${lines[0]} = "1..3" ]
  echo "$output" | grep "^ok . truth"
  echo "$output" | grep "^ok . more truth"
  echo "$output" | grep "^ok . quasi-truth"
}

@test "a failing test in a suite results in an error exit code" {
  FLUNK=1 run bats "$FIXTURE_ROOT/multiple"
  [ $status -eq 1 ]
  [ ${lines[0]} = "1..3" ]
  echo "$output" | grep "^not ok . quasi-truth"
}
