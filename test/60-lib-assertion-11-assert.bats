#!/usr/bin/env bats

load test_helper

@test 'assert() <expression>: returns 0 if <expression> evaluates to TRUE' {
  run assert true
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert() <expression>: returns 1 and displays details if <expression> evaluates to FALSE' {
  run bash -c 'echo "error"; false'
  run assert false
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ "${lines[0]}" == '-- assertion failed --' ]
  [ "${lines[1]}" == 'expression : false' ]
  [ "${lines[2]}" == 'status     : 1' ]
  [ "${lines[3]}" == 'output     : error' ]
  [ "${lines[4]}" == '--' ]
}

@test "assert() <expression>: displays details in multi-line format if \`\$output' is longer than one line" {
  run bash -c "echo $'0. error\n1. error'; false"
  run assert false
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 7 ]
  [ "${lines[0]}" == '-- assertion failed --' ]
  [ "${lines[1]}" == 'expression : false' ]
  [ "${lines[2]}" == 'status     : 1' ]
  [ "${lines[3]}" == 'output (2 lines):' ]
  [ "${lines[4]}" == '  0. error' ]
  [ "${lines[5]}" == '  1. error' ]
  [ "${lines[6]}" == '--' ]
}
