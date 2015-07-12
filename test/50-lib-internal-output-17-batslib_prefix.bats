#!/usr/bin/env bats

load test_helper

@test 'batslib_prefix() prefixes each line with the given string' {
  run bash -c "source '${BATS_LIB}/batslib.bash'; printf 'a\nb\nc\n' | batslib_prefix '_'"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '_a' ]
  [ "${lines[1]}" == '_b' ]
  [ "${lines[2]}" == '_c' ]
}

@test 'batslib_prefix() uses two spaces as default prefix' {
  run bash -c "source '${BATS_LIB}/batslib.bash'; printf 'a\nb\nc\n' | batslib_prefix"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '  a' ]
  [ "${lines[1]}" == '  b' ]
  [ "${lines[2]}" == '  c' ]
}

@test 'batslib_prefix() prefixes the last line when it is not terminated by a newline' {
  run bash -c "source '${BATS_LIB}/batslib.bash'; printf 'a\nb\nc' | batslib_prefix"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '  a' ]
  [ "${lines[1]}" == '  b' ]
  [ "${lines[2]}" == '  c' ]
}

@test 'batslib_prefix() prefixes empty lines' {
  run bash -c "source '${BATS_LIB}/batslib.bash'; printf '\n\n\n' | batslib_prefix"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '  ' ]
  [ "${lines[1]}" == '  ' ]
  [ "${lines[2]}" == '  ' ]
}
