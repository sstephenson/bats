#!/usr/bin/env bats

@test "echo and pass" {
	echo "this is a passing test"
	[ 1 -eq 1 ]
}

