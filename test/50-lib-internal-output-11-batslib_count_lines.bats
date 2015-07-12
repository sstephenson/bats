#!/usr/bin/env bats

load test_helper

@test 'batslib_count_lines() prints the number of lines in the input' {
  run batslib_count_lines $'a\nb\nc\n'
  [ "$status" -eq 0 ]
  [ "$output" == '3' ]
}

@test 'batslib_count_lines() counts last line when it is not terminated by a newline' {
  run batslib_count_lines $'a\nb\nc'
  [ "$status" -eq 0 ]
  [ "$output" == '3' ]
}

@test 'batslib_count_lines() counts empty lines' {
  run batslib_count_lines $'\n\n\n'
  [ "$status" -eq 0 ]
  [ "$output" == '3' ]
}
