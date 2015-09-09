#!/usr/bin/env bats

load test_helper

@test 'fail() returns 1' {
  run fail ''
  [ "$status" -eq 1 ]
}

@test 'fail() prints positional parameters' {
  run fail 'message'
  [ "$status" -eq 1 ]
  [ "$output" == 'message' ]
}

@test 'fail() prints STDIN if no positional parameters are specified' {
  run bash -c "source '${BATS_LIB}/batslib.bash'; echo 'message' | fail"
  [ "$status" -eq 1 ]
  [ "$output" == 'message' ]
}
