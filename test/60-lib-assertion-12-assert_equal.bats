#!/usr/bin/env bats

load test_helper

@test 'assert_equal() <actual> <expected>: returns 0 if <actual> equals <expected>' {
  run assert_equal 'a' 'a'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_equal() <actual> <expected>: returns 1 and displays details if <actual> does not equal <expected>' {
  run assert_equal 'a' 'b'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- values do not equal --' ]
  [ "${lines[1]}" == 'expected : b' ]
  [ "${lines[2]}" == 'actual   : a' ]
  [ "${lines[3]}" == '--' ]
}

@test 'assert_equal() <actual> <expected>: displays details in multi-line format if <actual> is longer than one line' {
  run assert_equal $'a 0\na 1' 'b'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 7 ]
  [ "${lines[0]}" == '-- values do not equal --' ]
  [ "${lines[1]}" == 'expected (1 lines):' ]
  [ "${lines[2]}" == '  b' ]
  [ "${lines[3]}" == 'actual (2 lines):' ]
  [ "${lines[4]}" == '  a 0' ]
  [ "${lines[5]}" == '  a 1' ]
  [ "${lines[6]}" == '--' ]
}

@test 'assert_equal() <actual> <expected>: displays details in multi-line format if <expected> is longer than one line' {
  run assert_equal 'a' $'b 0\nb 1'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 7 ]
  [ "${lines[0]}" == '-- values do not equal --' ]
  [ "${lines[1]}" == 'expected (2 lines):' ]
  [ "${lines[2]}" == '  b 0' ]
  [ "${lines[3]}" == '  b 1' ]
  [ "${lines[4]}" == 'actual (1 lines):' ]
  [ "${lines[5]}" == '  a' ]
  [ "${lines[6]}" == '--' ]
}

@test 'assert_equal() <actual> <expected>: performs literal matching' {
  run assert_equal 'a' '*'
  [ "$status" -eq 1 ]
}
