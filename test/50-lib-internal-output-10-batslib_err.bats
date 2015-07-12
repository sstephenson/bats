#!/usr/bin/env bats

load test_helper

@test 'batslib_err() prints positional parameters' {
  run batslib_err 'message'
  [ "$status" -eq 0 ]
  [ "$output" == 'message' ]
}

@test 'batslib_err() prints STDIN when no positional parameters are specified' {
  run bash -c "source '${BATS_LIB}/batslib.bash'; echo 'message' | batslib_err"
  [ "$status" -eq 0 ]
  [ "$output" == 'message' ]
}
