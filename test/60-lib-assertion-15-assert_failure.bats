#!/usr/bin/env bats

load test_helper

@test 'assert_failure() returns 0 if $status is not 0' {
  run false
  run assert_failure
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_failure() returns 1 and displays $output if $status is 0' {
  run bash -c 'echo ok; exit 0'
  run assert_failure
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- command succeeded, but it was expected to fail --' ]
  [ "${lines[1]}" == 'output : ok' ]
  [ "${lines[2]}" == '--' ]
}

@test 'assert_failure() displays $output in multi-line format if necessary' {
  run bash -c "echo $'ok 1\nok 2'; exit 0"
  run assert_failure
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ "${lines[0]}" == '-- command succeeded, but it was expected to fail --' ]
  [ "${lines[1]}" == 'output (2 lines):' ]
  [ "${lines[2]}" == '  ok 1' ]
  [ "${lines[3]}" == '  ok 2' ]
  [ "${lines[4]}" == '--' ]
}

@test 'assert_failure() tests $output against the first positional parameter if specified' {
  run bash -c 'echo a; exit 1'
  run assert_failure 'a'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_failure() displays the expected and actual output if they differ' {
  run bash -c 'echo b; exit 1'
  run assert_failure 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- command failed as expected, but output differs --' ]
  [ "${lines[1]}" == 'expected : a' ]
  [ "${lines[2]}" == 'actual   : b' ]
  [ "${lines[3]}" == '--' ]
}

@test 'assert_failure() displays the expected and actual output in multi-line format if necessary' {
  run bash -c "echo $'b 1\nb 2'; exit 1"
  run assert_failure 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 7 ]
  [ "${lines[0]}" == '-- command failed as expected, but output differs --' ]
  [ "${lines[1]}" == 'expected (1 lines):' ]
  [ "${lines[2]}" == '  a' ]
  [ "${lines[3]}" == 'actual (2 lines):' ]
  [ "${lines[4]}" == '  b 1' ]
  [ "${lines[5]}" == '  b 2' ]
  [ "${lines[6]}" == '--' ]
}

@test 'assert_failure() performs literal matching on $output' {
  run bash -c 'echo a; exit 1'
  run assert_failure '*'
  [ "$status" -eq 1 ]
}
