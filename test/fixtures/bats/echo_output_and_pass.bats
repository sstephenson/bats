@test "echo output and pass" {
	echo "Something from BATS file"
	$BATS_TEST_DIRNAME/echo_something.bash
	[ 0 -eq 0 ]
}
