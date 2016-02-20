#!/usr/bin/env bats

load test_helper

@test "assert_failure(): returns 0 if \`\$status' is not 0" {
  run false
  run assert_failure
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "assert_failure(): returns 1 and displays details if \`\$status' is 0" {
  run bash -c 'echo a; exit 0'
  run assert_failure
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- command succeeded, but it was expected to fail --' ]
  [ "${lines[1]}" == 'output : a' ]
  [ "${lines[2]}" == '--' ]
}

@test "assert_failure(): displays \`\$output' in multi-line format if it is longer then one line" {
  run bash -c "echo $'a 0\na 1'; exit 0"
  run assert_failure
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ "${lines[0]}" == '-- command succeeded, but it was expected to fail --' ]
  [ "${lines[1]}" == 'output (2 lines):' ]
  [ "${lines[2]}" == '  a 0' ]
  [ "${lines[3]}" == '  a 1' ]
  [ "${lines[4]}" == '--' ]
}

@test "assert_failure() <status>: returns 0 if \`\$status' equals <status>" {
  run bash -c 'exit 1'
  run assert_failure 1
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "assert_failure() <status>: returns 1 and displays details if \`\$status' does not equal <status>" {
  run bash -c 'echo a; exit 1'
  run assert_failure 2
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ "${lines[0]}" == '-- command failed as expected, but status differs --' ]
  [ "${lines[1]}" == 'expected : 2' ]
  [ "${lines[2]}" == 'actual   : 1' ]
  [ "${lines[3]}" == 'output   : a' ]
  [ "${lines[4]}" == '--' ]
}

@test "assert_failure() <status>: displays \`\$output' in multi-line format if it is longer then one line" {
  run bash -c "echo $'a 0\na 1'; exit 1"
  run assert_failure 2
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 7 ]
  [ "${lines[0]}" == '-- command failed as expected, but status differs --' ]
  [ "${lines[1]}" == 'expected : 2' ]
  [ "${lines[2]}" == 'actual   : 1' ]
  [ "${lines[3]}" == 'output (2 lines):' ]
  [ "${lines[4]}" == '  a 0' ]
  [ "${lines[5]}" == '  a 1' ]
  [ "${lines[6]}" == '--' ]
}
