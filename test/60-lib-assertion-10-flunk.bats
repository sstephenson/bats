#!/usr/bin/env bats

load test_helper

@test 'flunk() returns 1' {
  run flunk ''
  [ "$status" -eq 1 ]
}

@test 'flunk() prints positional parameters' {
  run flunk 'message'
  [ "$status" -eq 1 ]
  [ "$output" == 'message' ]
}

@test 'flunk() prints STDIN if no positional parameters are specified' {
  run bash -c "source '${BATS_LIB}/batslib.bash'; echo 'message' | flunk"
  [ "$status" -eq 1 ]
  [ "$output" == 'message' ]
}
