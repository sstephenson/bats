@test "echo output and pass" {
	echo "Something from BATS file"
	$BATS_TEST_DIRNAME/echo_something.bash
	[ 0 -eq 0 ]
}

@test "echo output and pass (using run)" {
        run $BATS_TEST_DIRNAME/echo_something.bash
        [ $status -eq 0 ]
}

