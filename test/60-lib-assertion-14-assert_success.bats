#!/usr/bin/env bats

load test_helper

@test 'assert_success() returns 0 if $status is 0' {
  run true
  run assert_success
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_success() returns 1 and displays $status and $output if $status is not 0' {
  run bash -c 'echo error; exit 1'
  run assert_success
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- command failed --' ]
  [ "${lines[1]}" == 'status : 1' ]
  [ "${lines[2]}" == 'output : error' ]
  [ "${lines[3]}" == '--' ]
}

@test 'assert_success() displays $output in multi-line format if necessary' {
  run bash -c "echo $'error 1\nerror 2'; exit 1"
  run assert_success
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 6 ]
  [ "${lines[0]}" == '-- command failed --' ]
  [ "${lines[1]}" == 'status : 1' ]
  [ "${lines[2]}" == 'output (2 lines):' ]
  [ "${lines[3]}" == '  error 1' ]
  [ "${lines[4]}" == '  error 2' ]
  [ "${lines[5]}" == '--' ]
}
