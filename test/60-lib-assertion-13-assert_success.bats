#!/usr/bin/env bats

load test_helper

@test "assert_success(): returns 0 if \`\$status' is 0" {
  run true
  run assert_success
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "assert_success(): returns 1 and displays details if \`\$status' is not 0" {
  run bash -c 'echo a; exit 1'
  run assert_success
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- command failed --' ]
  [ "${lines[1]}" == 'status : 1' ]
  [ "${lines[2]}" == 'output : a' ]
  [ "${lines[3]}" == '--' ]
}

@test "assert_success(): displays \`\$output' in multi-line format if it is longer than one line" {
  run bash -c "echo $'a 0\na 1'; exit 1"
  run assert_success
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 6 ]
  [ "${lines[0]}" == '-- command failed --' ]
  [ "${lines[1]}" == 'status : 1' ]
  [ "${lines[2]}" == 'output (2 lines):' ]
  [ "${lines[3]}" == '  a 0' ]
  [ "${lines[4]}" == '  a 1' ]
  [ "${lines[5]}" == '--' ]
}
