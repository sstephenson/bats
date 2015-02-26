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

@test "summary passing tests" {
  run filter_control_sequences bats -p $FIXTURE_ROOT/passing.bats
  [ $status -eq 0 ]
  [ "${lines[1]}" = "1 test, 0 failures" ]
}

@test "summary passing and skipping tests" {
  run filter_control_sequences bats -p $FIXTURE_ROOT/passing_and_skipping.bats
  [ $status -eq 0 ]
  [ "${lines[2]}" = "2 tests, 0 failures, 1 skipped" ]
}

@test "summary passing and failing tests" {
  run filter_control_sequences bats -p $FIXTURE_ROOT/failing_and_passing.bats
  [ $status -eq 0 ]
  [ "${lines[4]}" = "2 tests, 1 failure" ]
}

@test "summary passing, failing and skipping tests" {
  run filter_control_sequences bats -p $FIXTURE_ROOT/passing_failing_and_skipping.bats
  [ $status -eq 0 ]
  [ "${lines[5]}" = "3 tests, 1 failure, 1 skipped" ]
}

@test "one failing test" {
  run bats "$FIXTURE_ROOT/failing.bats"
  [ $status -eq 1 ]
  [ "${lines[0]}" = '1..1' ]
  [ "${lines[1]}" = 'not ok 1 a failing test' ]
  [ "${lines[2]}" = "# (in test file $RELATIVE_FIXTURE_ROOT/failing.bats, line 4)" ]
  [ "${lines[3]}" = "#   \`eval \"( exit \${STATUS:-1} )\"' failed" ]
}

@test "one failing and one passing test" {
  run bats "$FIXTURE_ROOT/failing_and_passing.bats"
  [ $status -eq 1 ]
  [ "${lines[0]}" = '1..2' ]
  [ "${lines[1]}" = 'not ok 1 a failing test' ]
  [ "${lines[2]}" = "# (in test file $RELATIVE_FIXTURE_ROOT/failing_and_passing.bats, line 2)" ]
  [ "${lines[3]}" = "#   \`false' failed" ]
  [ "${lines[4]}" = 'ok 2 a passing test' ]
}

@test "failing test with significant status" {
  STATUS=2 run bats "$FIXTURE_ROOT/failing.bats"
  [ $status -eq 1 ]
  [ "${lines[3]}" = "#   \`eval \"( exit \${STATUS:-1} )\"' failed with status 2" ]
}

@test "failing helper function logs the test case's line number" {
  run bats "$FIXTURE_ROOT/failing_helper.bats"
  [ $status -eq 1 ]
  [ "${lines[1]}" = 'not ok 1 failing helper function' ]
  [ "${lines[2]}" = "# (from function \`failing_helper' in file $RELATIVE_FIXTURE_ROOT/test_helper.bash, line 6," ]
  [ "${lines[3]}" = "#  in test file $RELATIVE_FIXTURE_ROOT/failing_helper.bats, line 5)" ]
  [ "${lines[4]}" = "#   \`failing_helper' failed" ]
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

@test "setup failure" {
  run bats "$FIXTURE_ROOT/failing_setup.bats"
  [ $status -eq 1 ]
  [ "${lines[1]}" = 'not ok 1 truth' ]
  [ "${lines[2]}" = "# (from function \`setup' in test file $RELATIVE_FIXTURE_ROOT/failing_setup.bats, line 2)" ]
  [ "${lines[3]}" = "#   \`false' failed" ]
}

@test "passing test with teardown failure" {
  PASS=1 run bats "$FIXTURE_ROOT/failing_teardown.bats"
  [ $status -eq 1 ]
  [ "${lines[1]}" = 'not ok 1 truth' ]
  [ "${lines[2]}" = "# (from function \`teardown' in test file $RELATIVE_FIXTURE_ROOT/failing_teardown.bats, line 2)" ]
  [ "${lines[3]}" = "#   \`eval \"( exit \${STATUS:-1} )\"' failed" ]
}

@test "failing test with teardown failure" {
  PASS=0 run bats "$FIXTURE_ROOT/failing_teardown.bats"
  [ $status -eq 1 ]
  [ "${lines[1]}" =  'not ok 1 truth' ]
  [ "${lines[2]}" =  "# (in test file $RELATIVE_FIXTURE_ROOT/failing_teardown.bats, line 6)" ]
  [ "${lines[3]}" = $'#   `[ "$PASS" = "1" ]\' failed' ]
}

@test "teardown failure with significant status" {
  PASS=1 STATUS=2 run bats "$FIXTURE_ROOT/failing_teardown.bats"
  [ $status -eq 1 ]
  [ "${lines[3]}" = "#   \`eval \"( exit \${STATUS:-1} )\"' failed with status 2" ]
}

@test "failing test file outside of BATS_CWD" {
  cd "$TMP"
  run bats "$FIXTURE_ROOT/failing.bats"
  [ $status -eq 1 ]
  [ "${lines[2]}" = "# (in test file $FIXTURE_ROOT/failing.bats, line 4)" ]
}

@test "load sources scripts relative to the current test file" {
  run bats "$FIXTURE_ROOT/load.bats"
  [ $status -eq 0 ]
}

@test "load aborts if the specified script does not exist" {
  HELPER_NAME="nonexistent" run bats "$FIXTURE_ROOT/load.bats"
  [ $status -eq 1 ]
}

@test "load sources scripts by absolute path" {
  HELPER_NAME="${FIXTURE_ROOT}/test_helper.bash" run bats "$FIXTURE_ROOT/load.bats"
  [ $status -eq 0 ]
}

@test "load aborts if the script, specified by an absolute path, does not exist" {
  HELPER_NAME="${FIXTURE_ROOT}/nonexistent" run bats "$FIXTURE_ROOT/load.bats"
  [ $status -eq 1 ]
}

@test "output is discarded for passing tests and printed for failing tests" {
  run bats "$FIXTURE_ROOT/output.bats"
  [ $status -eq 1 ]
  [ "${lines[6]}"  = '# failure stdout 1' ]
  [ "${lines[7]}"  = '# failure stdout 2' ]
  [ "${lines[11]}" = '# failure stderr' ]
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
  [ "${lines[1]}" = 'begin 1 a failing test' ]
  [ "${lines[2]}" = 'not ok 1 a failing test' ]
  [ "${lines[5]}" = 'begin 2 a passing test' ]
  [ "${lines[6]}" = 'ok 2 a passing test' ]
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

@test "single-line tests" {
  run bats "$FIXTURE_ROOT/single_line.bats"
  [ $status -eq 1 ]
  [ "${lines[1]}" =  'ok 1 empty' ]
  [ "${lines[2]}" =  'ok 2 passing' ]
  [ "${lines[3]}" =  'ok 3 input redirection' ]
  [ "${lines[4]}" =  'not ok 4 failing' ]
  [ "${lines[5]}" =  "# (in test file $RELATIVE_FIXTURE_ROOT/single_line.bats, line 9)" ]
  [ "${lines[6]}" = $'#   `@test "failing" { false; }\' failed' ]
}
