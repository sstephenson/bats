#!/usr/bin/env bats

load test_helper
fixtures bats

@test "no arguments prints usage instructions" {
  run bats
  [ $status -eq 1 ]
  [ $(expr "${lines[1]}" : "Usage:") -ne 0 ]
}

@test "-v and --version print version number" {
  run bats -v
  [ $status -eq 0 ]
  [ $(expr "$output" : "Bats [0-9][0-9.]*") -ne 0 ]
}

@test "-h and --help print help" {
  run bats -h
  [ $status -eq 0 ]
  [ "${#lines[@]}" -gt 3 ]
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
  [ ${lines[2]} = "# (in test file $FIXTURE_ROOT/failing.bats, line 4)" ]
}

@test "one failing and one passing test" {
  run bats "$FIXTURE_ROOT/failing_and_passing.bats"
  [ $status -eq 1 ]
  [ ${lines[0]} = "1..2" ]
  [ ${lines[1]} = "not ok 1 a failing test" ]
  [ ${lines[2]} = "# (in test file $FIXTURE_ROOT/failing_and_passing.bats, line 2)" ]
  [ ${lines[3]} = "ok 2 a passing test" ]
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

@test "load aborts if the specified script does not exist" {
  HELPER_NAME="nonexistent" run bats "$FIXTURE_ROOT/load.bats"
  [ $status -eq 1 ]
}

@test "output is discarded for passing tests and printed for failing tests" {
  run bats "$FIXTURE_ROOT/output.bats"
  [ $status -eq 1 ]
  [ "${lines[5]}" = "# failure stdout 1" ]
  [ "${lines[6]}" = "# failure stdout 2" ]
  [ "${lines[9]}" = "# failure stderr" ]
}

@test "-c prints the number of tests" {
  run bats -c "$FIXTURE_ROOT/empty.bats"
  [ $status -eq 0 ]
  [ "$output" = "0" ]

  run bats -c "$FIXTURE_ROOT/output.bats"
  [ $status -eq 0 ]
  [ "$output" = "4" ]
}

@test "dash-e is not mangled on beginning of line" {
  run bats "$FIXTURE_ROOT/intact.bats"
  [ $status -eq 0 ]
  [ "${lines[1]}" = "ok 1 dash-e on beginning of line" ]
}

@test "dos line endings are stripped before testing" {
  run bats "$FIXTURE_ROOT/dos_line.bats"
  [ $status -eq 0 ]
}

@test "test file without trailing newline" {
  run bats "$FIXTURE_ROOT/without_trailing_newline.bats"
  [ $status -eq 0 ]
  [ "${lines[1]}" = "ok 1 truth" ]
}

@test "skipped tests" {
  run bats "$FIXTURE_ROOT/skipped.bats"
  [ $status -eq 0 ]
  [ "${lines[1]}" = "ok 1 # skip a skipped test" ]
  [ "${lines[2]}" = "ok 2 # skip (a reason) a skipped test with a reason" ]
}

@test "extended syntax" {
  run bats-exec-test -x "$FIXTURE_ROOT/failing_and_passing.bats"
  [ $status -eq 1 ]
  [ "${lines[1]}" = "begin 1 a failing test" ]
  [ "${lines[2]}" = "not ok 1 a failing test" ]
  [ "${lines[4]}" = "begin 2 a passing test" ]
  [ "${lines[5]}" = "ok 2 a passing test" ]
}

@test "pretty and tap formats" {
  run bats --tap "$FIXTURE_ROOT/passing.bats"
  tap_output="$output"
  [ $status -eq 0 ]

  run bats --pretty "$FIXTURE_ROOT/passing.bats"
  pretty_output="$output"
  [ $status -eq 0 ]

  [ "$tap_output" != "$pretty_output" ]
}

@test "pretty formatter bails on invalid tap" {
  run bats --tap "$FIXTURE_ROOT/invalid_tap.bats"
  [ $status -eq 1 ]
  [ "${lines[0]}" = "This isn't TAP!" ]
  [ "${lines[1]}" = "Good day to you" ]
}

@test "failing helper function logs the test case's line number" {
  run bats "$FIXTURE_ROOT/failing_helper.bats"
  [ $status -eq 1 ]
  [ "${lines[1]}" = "not ok 1 failing helper function" ]
  [ "${lines[2]}" = "# (from function \`failing_helper' in file $FIXTURE_ROOT/test_helper.bash, line 6," ]
  [ "${lines[3]}" = "#  in test file $FIXTURE_ROOT/failing_helper.bats, line 5)" ]
}
