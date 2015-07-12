#!/usr/bin/env bats

load test_helper

@test 'refute_line() returns 0 if the unexpected line is not found' {
  run echo $'a\nb\nc'
  run refute_line 'd'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'refute_line() returns 1 and displays $output, the unexpected line and its index if it was found' {
  run echo $'b'
  run refute_line 'b'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ "${lines[0]}" == '-- line should not be in output --' ]
  [ "${lines[1]}" == 'line   : b' ]
  [ "${lines[2]}" == 'index  : 0' ]
  [ "${lines[3]}" == 'output : b' ]
  [ "${lines[4]}" == '--' ]
}

@test 'refute_line() displays $output in multi-line format with the unexpected line highlighted if necessary' {
  run echo $'a\nb\nc'
  run refute_line 'b'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 8 ]
  [ "${lines[0]}" == '-- line should not be in output --' ]
  [ "${lines[1]}" == 'line  : b' ]
  [ "${lines[2]}" == 'index : 1' ]
  [ "${lines[3]}" == 'output (3 lines):' ]
  [ "${lines[4]}" == '  a' ]
  [ "${lines[5]}" == '> b' ]
  [ "${lines[6]}" == '  c' ]
  [ "${lines[7]}" == '--' ]
}

@test 'refute_line() returns 0 if the unexpected line is not found at the given index' {
  run echo $'a\nb\nc'
  run refute_line 1 'd'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'refute_line() returns 1 and displays the unexpected line and the index if it was found at the given index' {
  run echo $'a\nb\nc'
  run refute_line 1 'b'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- line should differ from expected --' ]
  [ "${lines[1]}" == 'index : 1' ]
  [ "${lines[2]}" == 'line  : b' ]
  [ "${lines[3]}" == '--' ]
}

@test 'refute_line() performs literal matching when the unexpected line is sought in the entire output' {
  run echo $'a\nb\nc'
  run refute_line '*'
  [ "$status" -eq 0 ]
}

@test 'refute_line() performs literal matching when the unexpected line is sought at a given index' {
  run echo $'a\nb\nc'
  run refute_line 1 '*'
  [ "$status" -eq 0 ]
}
