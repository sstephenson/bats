#!/usr/bin/env bats

load test_helper

@test 'assert() returns 0 if the condition evaluates to TRUE' {
  run assert true
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert() returns 1 and displays the condition if it evaluates to FALSE' {
  run assert false
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- assertion failed --' ]
  [ "${lines[1]}" == 'condition : false' ]
  [ "${lines[2]}" == '--' ]
}
