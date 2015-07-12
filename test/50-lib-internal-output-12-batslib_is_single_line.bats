#!/usr/bin/env bats

load test_helper

@test 'batslib_is_single_line() returns 0 if all parameters are one-line strings' {
  run batslib_is_single_line 'a' $'b\n' 'c'
  [ "$status" -eq 0 ]
}

@test 'batslib_is_single_line() returns 1 if at least one parameter is longer than one line' {
  run batslib_is_single_line 'a' $'b\nb' 'c'
  [ "$status" -eq 1 ]
}
