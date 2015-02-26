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

@test "running an ad-hoc suite by specifying multiple test files" {
  run bats "$FIXTURE_ROOT/multiple/a.bats" "$FIXTURE_ROOT/multiple/b.bats"
  [ $status -eq 0 ]
  [ ${lines[0]} = "1..3" ]
  echo "$output" | grep "^ok . truth"
  echo "$output" | grep "^ok . more truth"
  echo "$output" | grep "^ok . quasi-truth"
}

@test "extended syntax in suite" {
  FLUNK=1 run bats-exec-suite -x "$FIXTURE_ROOT/multiple/"*.bats
  [ $status -eq 1 ]
  [ "${lines[0]}" = "1..3" ]
  [ "${lines[1]}" = "begin 1 truth" ]
  [ "${lines[2]}" = "ok 1 truth" ]
  [ "${lines[3]}" = "begin 2 more truth" ]
  [ "${lines[4]}" = "ok 2 more truth" ]
  [ "${lines[5]}" = "begin 3 quasi-truth" ]
  [ "${lines[6]}" = "not ok 3 quasi-truth" ]
}
