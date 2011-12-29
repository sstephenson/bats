# Bats: the Bash Automated Testing System

Bats is a [TAP](http://testanything.org/)-compliant testing framework
for Bash. It provides a simple way to verify that the UNIX programs
you write behave as expected.

A Bats test file is a Bash script with special syntax for defining
test cases. Under the hood, each test case is just a function with a
description.

```bash
#!/usr/bin/env bats

@test "addition using bc" {
  result="$(echo 2+2 | bc)"
  [ "$result" -eq 4 ]
}

@test "addition using dc" {
  result="$(echo 2 2+p | dc)"
  [ "$result" -eq 4 ]
}
```

Test cases consist of standard shell commands. Bats makes use of
Bash's `errexit` (`set -e`) option when running test cases. If every
command in the test case exits with a `0` status code (success), the
test passes. In this way, each line is an assertion of truth.

To run your tests, invoke the `bats` interpreter with a path to a test
file. The file's test cases are run sequentially and in isolation, and
the results are written to standard output in human-readable TAP
format. If all the test cases pass, `bats` exits with a `0` status
code. If there is a failure, `bats` exits with a `1` status code.

    $ bats addition.bats
    1..2
    ok 1 addition using bc
    ok 2 addition using dc
    $ echo $?
    0

You can also define special `setup` and `teardown` functions which run
before and after each test case, respectively. Use these to load
fixtures, set up your environment, and clean up when you're done.

Bats is most useful when testing software written in Bash, but you can
use it to test any UNIX program.
