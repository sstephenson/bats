#!/usr/bin/env bats

@test "echo and fail" {
	echo "this is a failing test"
	[ 0 -eq 1 ]
}

