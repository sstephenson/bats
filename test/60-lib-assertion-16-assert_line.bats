#!/usr/bin/env bats

load test_helper

@test 'assert_line() returns 0 if the expected line is found' {
  run echo $'a\nb\nc'
  run assert_line 'b'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_line() returns 1 and displays $output and the expected line if it was not found' {
  run echo 'a'
  run assert_line 'd'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- line is not in output --' ]
  [ "${lines[1]}" == 'line   : d' ]
  [ "${lines[2]}" == 'output : a' ]
  [ "${lines[3]}" == '--' ]
}

@test 'assert_line() displays $output in multi-line format if necessary' {
  run echo $'a\nb\nc'
  run assert_line 'd'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 7 ]
  [ "${lines[0]}" == '-- line is not in output --' ]
  [ "${lines[1]}" == 'line : d' ]
  [ "${lines[2]}" == 'output (3 lines):' ]
  [ "${lines[3]}" == '  a' ]
  [ "${lines[4]}" == '  b' ]
  [ "${lines[5]}" == '  c' ]
  [ "${lines[6]}" == '--' ]
}

@test 'assert_line() returns 0 if the expected line is found at the given index' {
  run echo $'a\nb\nc'
  run assert_line 1 'b'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_line() returns 1 and displays the expected and the actual line at the given index if they do not equal' {
  run echo $'a\nb\nc'
  run assert_line 1 'd'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ "${lines[0]}" == '-- line differs --' ]
  [ "${lines[1]}" == 'index    : 1' ]
  [ "${lines[2]}" == 'expected : d' ]
  [ "${lines[3]}" == 'actual   : b' ]
  [ "${lines[4]}" == '--' ]
}

@test 'assert_line() performs literal matching when the expected line is sought in the entire output' {
  run echo $'a\nb\nc'
  run assert_line '*'
  [ "$status" -eq 1 ]
}

@test 'assert_line() performs literal matching when the expected line is sought at a given index' {
  run echo $'a\nb\nc'
  run assert_line 1 '*'
  [ "$status" -eq 1 ]
}
