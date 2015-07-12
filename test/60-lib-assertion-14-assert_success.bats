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

@test 'assert_success() tests $output against the first positional parameter if specified' {
  run echo 'a'
  run assert_success 'a'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_success() displays the expected and actual output if they differ' {
  run echo 'b'
  run assert_success 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- command succeeded, but output differs --' ]
  [ "${lines[1]}" == 'expected : a' ]
  [ "${lines[2]}" == 'actual   : b' ]
  [ "${lines[3]}" == '--' ]
}

@test 'assert_success() displays the expected and actual output in multi-line format if necessary' {
  run echo $'b 1\nb 2'
  run assert_success 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 7 ]
  [ "${lines[0]}" == '-- command succeeded, but output differs --' ]
  [ "${lines[1]}" == 'expected (1 lines):' ]
  [ "${lines[2]}" == '  a' ]
  [ "${lines[3]}" == 'actual (2 lines):' ]
  [ "${lines[4]}" == '  b 1' ]
  [ "${lines[5]}" == '  b 2' ]
  [ "${lines[6]}" == '--' ]
}

@test 'assert_success() performs literal matching on $output' {
  run echo 'a'
  run assert_success '*'
  [ "$status" -eq 1 ]
}
