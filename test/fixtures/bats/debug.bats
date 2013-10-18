#!/usr/bin/env bats

@test "this test contains decho call" {
  decho "testing decho"
  [[ 1 -eq 1 ]]
}
