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

@test 'assert_failure() test $status against the first positional parameter if specified' {
  run bash -c 'echo ok; exit 1'
  run assert_failure 1
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_failure() displays $output, and the expected and actual status if they differ' {
  run bash -c 'echo error; exit 1'
  run assert_failure 2
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ "${lines[0]}" == '-- command failed as expected, but status differs --' ]
  [ "${lines[1]}" == 'expected : 2' ]
  [ "${lines[2]}" == 'actual   : 1' ]
  [ "${lines[3]}" == 'output   : error' ]
  [ "${lines[4]}" == '--' ]
}

@test 'assert_failure() when status differs, displays $output in multi-line format if necessary' {
  run bash -c "echo $'error 1\nerror 2'; exit 1"
  run assert_failure 2
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 7 ]
  [ "${lines[0]}" == '-- command failed as expected, but status differs --' ]
  [ "${lines[1]}" == 'expected : 2' ]
  [ "${lines[2]}" == 'actual   : 1' ]
  [ "${lines[3]}" == 'output (2 lines):' ]
  [ "${lines[4]}" == '  error 1' ]
  [ "${lines[5]}" == '  error 2' ]
  [ "${lines[6]}" == '--' ]
}
