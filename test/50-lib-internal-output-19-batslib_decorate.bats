#!/usr/bin/env bats

load test_helper

@test 'batslib_decorate() <title>: encloses the input in a footer line and a header line containing <title>' {
  run bash -c "source '${BATS_LIB}/batslib.bash'; echo 'body' | batslib_decorate 'title'"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- title --' ]
  [ "${lines[1]}" == 'body' ]
  [ "${lines[2]}" == '--' ]
}
