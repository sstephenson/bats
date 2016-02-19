@test "echo output and fail" {
	echo "Something from echo_output_and_fail.bats"
	$BATS_TEST_DIRNAME/echo_something.bash
	[ 0 -eq 1 ]
}
