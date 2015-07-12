#!/usr/bin/env bats

load test_helper

@test 'assert_output() returns 0 if $output equals the expected output' {
  run echo 'a'
  run assert_output 'a'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_output() returns 1 and displays the expected and actual output if they do not equal' {
  run echo 'b'
  run assert_output 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- output differs --' ]
  [ "${lines[1]}" == 'expected : a' ]
  [ "${lines[2]}" == 'actual   : b' ]
  [ "${lines[3]}" == '--' ]
}

@test 'assert_output() displays the expected and actual output in multi-line format if necessary' {
  run echo $'b 1\nb 2'
  run assert_output 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 7 ]
  [ "${lines[0]}" == '-- output differs --' ]
  [ "${lines[1]}" == 'expected (1 lines):' ]
  [ "${lines[2]}" == '  a' ]
  [ "${lines[3]}" == 'actual (2 lines):' ]
  [ "${lines[4]}" == '  b 1' ]
  [ "${lines[5]}" == '  b 2' ]
  [ "${lines[6]}" == '--' ]
}

@test 'assert_output() reads the expected output from STDIN when no positional parameters are specified' {
  run echo 'a'
  export output
  run bash -c "source '${BATS_LIB}/batslib.bash'; echo 'a' | assert_output"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_output() performs literal matching' {
  run echo '*'
  run assert_output 'a'
  [ "$status" -eq 1 ]
}
