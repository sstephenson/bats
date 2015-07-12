#!/usr/bin/env bats

load test_helper

@test 'batslib_mark() highlights a single line' {
  run bash -c "source '${BATS_LIB}/batslib.bash'; printf ' a\n b\n c\n' | batslib_mark '>' 0"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '>a' ]
  [ "${lines[1]}" == ' b' ]
  [ "${lines[2]}" == ' c' ]
}

@test 'batslib_mark() highlights lines when indices are in ascending order' {
  run bash -c "source '${BATS_LIB}/batslib.bash'; printf ' a\n b\n c\n' | batslib_mark '>' 1 2"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == ' a' ]
  [ "${lines[1]}" == '>b' ]
  [ "${lines[2]}" == '>c' ]
}

@test 'batslib_mark() highlights lines when indices are in random order' {
  run bash -c "source '${BATS_LIB}/batslib.bash'; printf ' a\n b\n c\n' | batslib_mark '>' 2 1"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == ' a' ]
  [ "${lines[1]}" == '>b' ]
  [ "${lines[2]}" == '>c' ]
}

@test 'batslib_mark() ignores duplicate line indices' {
  run bash -c "source '${BATS_LIB}/batslib.bash'; printf ' a\n b\n c\n' | batslib_mark '>' 1 2 1"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == ' a' ]
  [ "${lines[1]}" == '>b' ]
  [ "${lines[2]}" == '>c' ]
}

@test 'batslib_mark() outputs the input untouched if the marking string is the empty string' {
  run bash -c "source '${BATS_LIB}/batslib.bash'; printf ' a\n b\n c\n' | batslib_mark '' 1"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == ' a' ]
  [ "${lines[1]}" == ' b' ]
  [ "${lines[2]}" == ' c' ]
}

@test 'batslib_mark() highlights the last line when it is not terminated by a newline' {
  run bash -c "source '${BATS_LIB}/batslib.bash'; printf ' a\n b\n c' | batslib_mark '>' 2"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == ' a' ]
  [ "${lines[1]}" == ' b' ]
  [ "${lines[2]}" == '>c' ]
}

@test 'batslib_mark() replaces the line with the marking string if the line is shorter or equally long' {
  run bash -c "source '${BATS_LIB}/batslib.bash'; printf '\n' | batslib_mark '>' 0"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 1 ]
  [ "${lines[0]}" == '>' ]
}
