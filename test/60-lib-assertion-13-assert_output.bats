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
  run echo 'a'
  run assert_output '*'
  [ "$status" -eq 1 ]
}


#
# -l <index>
#

@test 'assert_output() -l <index> returns 0 if the expected line is found at the given index' {
  run echo $'a\nb\nc'
  run assert_output -l 1 'b'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_output() -l <index> returns 1 and displays the index, and the expected and actual line at the given index if they do not equal' {
  run echo $'a\nb\nc'
  run assert_output -l 1 'd'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ "${lines[0]}" == '-- line differs --' ]
  [ "${lines[1]}" == 'index    : 1' ]
  [ "${lines[2]}" == 'expected : d' ]
  [ "${lines[3]}" == 'actual   : b' ]
  [ "${lines[4]}" == '--' ]
}

@test 'assert_output() -l <index> reads the expected output from STDIN when no positional parameters are specified' {
  run echo $'a\nb\nc'
  export output
  run bash -c "lines=${lines[@]}; source '${BATS_LIB}/batslib.bash'; echo 'b' | assert_output -l 1"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_output() -l <index> performs literal matching' {
  run echo $'a\nb\nc'
  run assert_output -l 1 '*'
  [ "$status" -eq 1 ]
}

@test 'assert_output() -l without <index> returns 1 and displays an error message' {
  run echo $'a\nb\nc'
  run assert_output -l 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- ERROR: assert_output --' ]
  [ "${lines[1]}" == "\`-l' requires an integer argument" ]
  [ "${lines[2]}" == '--' ]
}

@test 'assert_output() -l without <index> returns 1 and displays an error message when reading the expected output from STDIN' {
  run echo $'a\nb\nc'
  run bash -c "source '${BATS_LIB}/batslib.bash'; echo 'a' | assert_output -l"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- ERROR: assert_output --' ]
  [ "${lines[1]}" == "\`-l' requires an integer argument" ]
  [ "${lines[2]}" == '--' ]
}


#
# -L
#

@test 'assert_output() -L returns 0 if the expected line is found' {
  run echo $'a\nb\nc'
  run assert_output -L 'b'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_output() -L returns 1 and displays $output and the expected line if it was not found' {
  run echo 'a'
  run assert_output -L 'b'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- line is not in output --' ]
  [ "${lines[1]}" == 'line   : b' ]
  [ "${lines[2]}" == 'output : a' ]
  [ "${lines[3]}" == '--' ]
}

@test 'assert_output() -L displays $output in multi-line format if necessary' {
  run echo $'a\nb\nc'
  run assert_output -L 'd'
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

@test 'assert_output() -L performs literal matching' {
  run echo $'a\nb\nc'
  run assert_output -l 1 '*'
  [ "$status" -eq 1 ]
}


#
# Options.
#

@test 'assert_output() -l and -L are mutually exclusive' {
  run echo $'a\nb\nc'
  run assert_output -l 1 -L 'b'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- ERROR: assert_output --' ]
  [ "${lines[1]}" == "\`-l' and \`-L' are mutually exclusive" ]
  [ "${lines[2]}" == '--' ]
}
