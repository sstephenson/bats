#!/usr/bin/env bats

load test_helper

@test 'assert_equal() returns 0 if the actual value equals the expected' {
  run assert_equal 'a' 'a'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_equal() returns 1 and displays the actual and expected value if they do not equal' {
  run assert_equal 'a' 'b'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- values do not equal --' ]
  [ "${lines[1]}" == 'expected : a' ]
  [ "${lines[2]}" == 'actual   : b' ]
  [ "${lines[3]}" == '--' ]
}

@test 'assert_equal() displays the expected and actual value in multi-line format if necessary' {
  run assert_equal 'a' $'b 1\nb 2'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 7 ]
  [ "${lines[0]}" == '-- values do not equal --' ]
  [ "${lines[1]}" == 'expected (1 lines):' ]
  [ "${lines[2]}" == '  a' ]
  [ "${lines[3]}" == 'actual (2 lines):' ]
  [ "${lines[4]}" == '  b 1' ]
  [ "${lines[5]}" == '  b 2' ]
  [ "${lines[6]}" == '--' ]
}

@test 'assert_equal() performs literal matching' {
  run assert_equal 'a' '*'
  [ "$status" -eq 1 ]
}
