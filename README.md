# Bats: Bash Automated Testing System

Bats is a [TAP](http://testanything.org)-compliant testing framework
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

Bats is most useful when testing software written in Bash, but you can
use it to test any UNIX program.

Test cases consist of standard shell commands. Bats makes use of
Bash's `errexit` (`set -e`) option when running test cases. If every
command in the test case exits with a `0` status code (success), the
test passes. In this way, each line is an assertion of truth.


## Running tests

To run your tests, invoke the `bats` interpreter with a path to a test
file. The file's test cases are run sequentially and in isolation. If
all the test cases pass, `bats` exits with a `0` status code. If there
are any failures, `bats` exits with a `1` status code.

When you run Bats from a terminal, you'll see output as each test is
performed, with a check-mark next to the test's name if it passes or
an "X" if it fails.

    $ bats addition.bats
     ✓ addition using bc
     ✓ addition using dc

    2 tests, 0 failures

If Bats is not connected to a terminal—in other words, if you
run it from a continuous integration system, or redirect its output to
a file—the results are displayed in human-readable, machine-parsable
[TAP format](http://testanything.org).

You can force TAP output from a terminal by invoking Bats with the
`--tap` option.

    $ bats --tap addition.bats
    1..2
    ok 1 addition using bc
    ok 2 addition using dc

### Test suites

You can invoke the `bats` interpreter with multiple test file
arguments, or with a path to a directory containing multiple `.bats`
files. Bats will run each test file individually and aggregate the
results. If any test case fails, `bats` exits with a `1` status code.


## Writing tests

Each Bats test file is evaluated _n+1_ times, where _n_ is the number of
test cases in the file. The first run counts the number of test cases,
then iterates over the test cases and executes each one in its own
process.

For more details about how Bats evaluates test files, see 
[Bats Evaluation Process](https://github.com/sstephenson/bats/wiki/Bats-Evaluation-Process)
on the wiki.

### `run`: Test other commands

Many Bats tests need to run a command and then make assertions about
its exit status and output. Bats includes a `run` helper that invokes
its arguments as a command, saves the exit status and output into
special global variables, and then returns with a `0` status code so
you can continue to make assertions in your test case.

For example, let's say you're testing that the `foo` command, when
passed a nonexistent filename, exits with a `1` status code and prints
an error message.

```bash
@test "invoking foo with a nonexistent file prints an error" {
  run foo nonexistent_filename
  [ "$status" -eq 1 ]
  [ "$output" = "foo: no such file 'nonexistent_filename'" ]
}
```

The `$status` variable contains the status code of the command, and
the `$output` variable contains the combined contents of the command's
standard output and standard error streams.

A third special variable, the `$lines` array, is available for easily
accessing individual lines of output. For example, if you want to test
that invoking `foo` without any arguments prints usage information on
the first line:

```bash
@test "invoking foo without arguments prints usage" {
  run foo
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "usage: foo <filename>" ]
}
```

Bats, as part of its [Standard Library](#standard-library), provides
[assertion](#assertions) type helper functions that perform a test and
output useful details when the test fails.

### `load`: Share common code

You may want to share common code across multiple test files. Bats
includes a convenient `load` command for sourcing a Bash source file
relative to the location of the current test file. For example, if you
have a Bats test in `test/foo.bats`, the command

```bash
load test_helper
```

will source the script `test/test_helper.bash` in your test file. This
can be useful for sharing functions to set up your environment or load
fixtures.

### `skip`: Easily skip tests

Tests can be skipped by using the `skip` command at the point in a
test you wish to skip.

```bash
@test "A test I don't want to execute for now" {
  skip
  run foo
  [ "$status" -eq 0 ]
}
```

Optionally, you may include a reason for skipping:

```bash
@test "A test I don't want to execute for now" {
  skip "This command will return zero soon, but not now"
  run foo
  [ "$status" -eq 0 ]
}
```

Or you can skip conditionally:

```bash
@test "A test which should run" {
  if [ foo != bar ]; then
    skip "foo isn't bar"
  fi

  run foo
  [ "$status" -eq 0 ]
}
```

### `setup` and `teardown`: Pre- and post-test hooks

You can define special `setup` and `teardown` functions, which run
before and after each test case, respectively. Use these to load
fixtures, set up your environment, and clean up when you're done.

### Code outside of test cases

You can include code in your test file outside of `@test` functions.
For example, this may be useful if you want to check for dependencies
and fail immediately if they're not present. However, any output that
you print in code outside of `@test`, `setup` or `teardown` functions
must be redirected to `stderr` (`>&2`). Otherwise, the output may
cause Bats to fail by polluting the TAP stream on `stdout`.

### Special variables

There are several global variables you can use to introspect on Bats
tests:

* `$BATS_TEST_FILENAME` is the fully expanded path to the Bats test
file.
* `$BATS_TEST_DIRNAME` is the directory in which the Bats test file is
located.
* `$BATS_TEST_NAMES` is an array of function names for each test case.
* `$BATS_TEST_NAME` is the name of the function containing the current
test case.
* `$BATS_TEST_DESCRIPTION` is the description of the current test
case.
* `$BATS_TEST_NUMBER` is the (1-based) index of the current test case
in the test file.
* `$BATS_TMPDIR` is the location to a directory that may be used to
store temporary files.
* `$BATS_LIB` is the directory in which the Standard Library is located.


## Standard library

The Standard Library is a collection of test helpers intended to
simplify testing. It helps building test suits that provide relevant
information when a test fails to speed up debugging.

It contains the following types of test helpers.

* [**Assertions**](#assertions) are functions that perform a test and
  output relevant information on failure to help debugging.

Test helpers send all output to the standard error, making them usable
outside of `@test` functions too. Output is [formatted](#output) for
readability.

The Standard Library is automatically loaded and available in all test
files.

### Output

On failure, in addition to the usual output generated by Bats,
[**Assertions**](#assertions) display information relevant to the failed
test to help debugging. The output is formatted for readability and
displayed as key-value pairs on the standard error.

When the value is one line long, the pair is displayed in a columnar
fashion called ***two-column*** format.

```
-- output differs --
expected : want
actual   : have
--
```

When the value is longer than one line, the number of lines in the value
is displayed after the key, and the value starts on the next line and is
indented by two spaces for added readability. This is called
***multi-line*** format.

For convenience, sometimes related values are also displayed in this
format even if they are only one line long.

```
-- output differs --
expected (1 lines):
  want
actual (3 lines):
  have 1
  have 2
  have 3
--
```

### Assertions

Assertions are functions that perform a test and output relevant
information on failure to help debugging. They return `1` on failure and
`0` otherwise.

Assertions about exit code and output operate on the results of the most
recent invocation of `run`.

#### `fail`

Display an error message and fail. This function provides a convenient
way to report failure in arbitrary situations. You can use it to
implement your own helpers when the ones available do not meet your
needs. Other functions use it internally as well.

```bash
@test 'fail()' {
  fail 'this test always fails'
}
```

The message can also be specified on the standard input.

```bash
@test 'fail() with pipe' {
  echo 'this test always fails' | fail
}
```

This function always fails and simply outputs the given message.

```
this test always fails
```

#### `assert`

Fail if the given expression evaluates to false.

***Note:*** *The expression must be a simple command. [Compound
commands](https://www.gnu.org/software/bash/manual/bash.html#Compound-Commands),
such as `[[`, can be used only when executed with `bash -c`.

```bash
@test 'assert()' {
  run touch '/var/log/test.log'
  assert [ -e '/var/log/test.log' ]
}
```

On failure, the failed expression, `$status` and `$output` are
displayed.

```
-- assertion failed --
expression : [ -e /var/log/test.log ]
status     : 1
output     : touch: cannot touch ‘/var/log/test.log’: Permission denied
--
```

If `$output` is longer than one line, it is displayed in *multi-line*
format.

#### `assert_equal`

Fail if the two parameters, actual and expected value respectively, do
not equal.

```bash
@test 'assert_equal()' {
  assert_equal 'have' 'want'
}
```

On failure, the expected and actual values are displayed.

```
-- values do not equal --
expected : want
actual   : have
--
```

If either value is longer than one line both are displayed in
*multi-line* format.

#### `assert_success`

Fail if `$status` is not 0.

```bash
@test 'assert_success() status only' {
  run bash -c "echo 'Error!'; exit 1"
  assert_success
}
```

On failure, `$status` and `$output` are displayed.

```
-- command failed --
status : 1
output : Error!
--
```

If `$output` is longer than one line, it is displayed in *multi-line*
format.

#### `assert_failure`

Fail if `$status` is 0.

```bash
@test 'assert_failure() status only' {
  run echo 'Success!'
  assert_failure
}
```

On failure, `$output` is displayed.

```
-- command succeeded, but it was expected to fail --
output : Success!
--
```

If `$output` is longer than one line, it is displayed in *multi-line*
format.

##### Expected status

When one parameter is specified, fail if `$status` does not equal the
expected status specified by the parameter.

```bash
@test 'assert_failure() with expected status' {
  run bash -c "echo 'Error!'; exit 1"
  assert_failure 2
}
```

On failure, the expected and actual status, and `$output` are displayed.

```
-- command failed as expected, but status differs --
expected : 2
actual   : 1
output   : Error!
--
```

If `$output` is longer than one line, it is displayed in *multi-line*
format.

#### `assert_output`

This function helps to verify that a command or function produces the
correct output by checking that the specified expected output matches
the actual output. Matching can be literal (default), partial or regular
expression. This function is the logical complement of `refute_output`.

##### Literal matching

By default, literal matching is performed. The assertion fails if
`$output` does not equal the expected output.

```bash
@test 'assert_output()' {
  run echo 'have'
  assert_output 'want'
}
```

On failure, the expected and actual output are displayed.

```
-- output differs --
expected : want
actual   : have
--
```

If either value is longer than one line both are displayed in
*multi-line* format.

##### Partial matching

Partial matching can be enabled with the `--partial` option (`-p` for
short). When used, the assertion fails if the expected *substring* is
not found in `$output`.

```bash
@test 'assert_output() partial matching' {
  run echo 'ERROR: no such file or directory'
  assert_output --partial 'SUCCESS'
}
```

On failure, the substring and the output are displayed.

```
-- output does not contain substring --
substring : SUCCESS
output    : ERROR: no such file or directory
--
```

This option and regular expression matching (`--regexp` or `-e`) are
mutually exclusive. An error is displayed when used simultaneously.

##### Regular expression matching

Regular expression matching can be enabled with the `--regexp` option
(`-e` for short). When used, the assertion fails if the *extended
regular expression* does not match `$output`.

*Note: The anchors `^` and `$` bind to the beginning and the end of the
entire output (not individual lines), respectively.*

```bash
@test 'assert_output() regular expression matching' {
  run echo 'Foobar 0.1.0'
  assert_output --regexp '^Foobar v[0-9]+\.[0-9]+\.[0-9]$'
}
```

On failure, the regular expression and the output are displayed.

```
-- regular expression does not match output --
regexp : ^Foobar v[0-9]+\.[0-9]+\.[0-9]$
output : Foobar 0.1.0
--
```

An error is displayed if the specified extended regular expression is
invalid.

This option and partial matching (`--partial` or `-p`) are mutually
exclusive. An error is displayed when used simultaneously.

#### `refute_output`

This function helps to verify that a command or function produces the
correct output by checking that the specified unexpected output does not
match the actual output. Matching can be literal (default), partial or
regular expression. This function is the logical complement of
`assert_output`.


##### Literal matching

By default, literal matching is performed. The assertion fails if
`$output` equals the unexpected output.

```bash
@test 'refute_output()' {
  run echo 'want'
  refute_output 'want'
}
```

On failure, the output is displayed.

```
-- output equals, but it was expected to differ --
output : want
--
```

If output is longer than one line it is displayed in *multi-line*
format.

##### Partial matching

Partial matching can be enabled with the `--partial` option (`-p` for
short). When used, the assertion fails if the unexpected *substring* is
found in `$output`.

```bash
@test 'refute_output() partial matching' {
  run echo 'ERROR: no such file or directory'
  refute_output --partial 'ERROR'
}
```

On failure, the substring and the output are displayed.

```
-- output should not contain substring --
substring : ERROR
output    : ERROR: no such file or directory
--
```

This option and regular expression matching (`--regexp` or `-e`) are
mutually exclusive. An error is displayed when used simultaneously.

##### Regular expression matching

Regular expression matching can be enabled with the `--regexp` option
(`-e` for short). When used, the assertion fails if the *extended
regular expression* matches `$output`.

*Note: The anchors `^` and `$` bind to the beginning and the end of the
entire output (not individual lines), respectively.*

```bash
@test 'refute_output() regular expression matching' {
  run echo 'Foobar v0.1.0'
  refute_output --regexp '^Foobar v[0-9]+\.[0-9]+\.[0-9]$'
}
```

On failure, the regular expression and the output are displayed.

```
-- regular expression should not match output --
regexp : ^Foobar v[0-9]+\.[0-9]+\.[0-9]$
output : Foobar v0.1.0
--
```

An error is displayed if the specified extended regular expression is
invalid.

This option and partial matching (`--partial` or `-p`) are mutually
exclusive. An error is displayed when used simultaneously.

#### `assert_line`

Similarly to `assert_output`, this function helps to verify that a
command or function produces the correct output. It checks that the
expected line appears in the output (default) or in a specific line of
it. Matching can be literal (default), partial or regular expression.
This function is the logical complement of `refute_line`.

***Warning:*** *Due to a [bug in Bats][bats-93], empty lines are
discarded from `${lines[@]}`, causing line indices to change and
preventing testing for empty lines.*

[bats-93]: https://github.com/sstephenson/bats/pull/93

##### Looking for a line in the output

By default, the entire output is searched for the expected line. The
assertion fails if the expected line is not found in `${lines[@]}`.

```bash
@test 'assert_line() looking for line' {
  run echo $'have-0\nhave-1\nhave-2'
  assert_line 'want'
}
```

On failure, the expected line and the output are displayed.

***Warning:*** *The output displayed does not contain empty lines. See
the Warning above for more.*

```
-- output does not contain line --
line : want
output (3 lines):
  have-0
  have-1
  have-2
--
```

If output is not longer than one line, it is displayed in *two-column*
format.

##### Matching a specific line

When the `--index <idx>` option is used (`-n <idx>` for short) , the
expected line is matched only against the line identified by the given
index. The assertion fails if the expected line does not equal
`${lines[<idx>]}`.

```bash
@test 'assert_line() specific line' {
  run echo $'have-0\nhave-1\nhave-2'
  assert_line --index 1 'want-1'
}
```

On failure, the index and the compared lines are displayed.

```
-- line differs --
index    : 1
expected : want-1
actual   : have-1
--
```

##### Partial matching

Partial matching can be enabled with the `--partial` option (`-p` for
short). When used, a match fails if the expected *substring* is not
found in the matched line.

```bash
@test 'assert_line() partial matching' {
  run echo $'have 1\nhave 2\nhave 3'
  assert_line --partial 'want'
}
```

On failure, the same details are displayed as for literal matching,
except that the substring replaces the expected line.

```
-- no output line contains substring --
substring : want
output (3 lines):
  have 1
  have 2
  have 3
--
```

This option and regular expression matching (`--regexp` or `-e`) are
mutually exclusive. An error is displayed when used simultaneously.

##### Regular expression matching

Regular expression matching can be enabled with the `--regexp` option
(`-e` for short). When used, a match fails if the *extended regular
expression* does not match the line being tested.

*Note: As expected, the anchors `^` and `$` bind to the beginning and
the end of the matched line, respectively.*

```bash
@test 'assert_line() regular expression matching' {
  run echo $'have-0\nhave-1\nhave-2'
  assert_line --index 1 --regexp '^want-[0-9]$'
}
```

On failure, the same details are displayed as for literal matching,
except that the regular expression replaces the expected line.

```
-- regular expression does not match line --
index  : 1
regexp : ^want-[0-9]$
line   : have-1
--
```

An error is displayed if the specified extended regular expression is
invalid.

This option and partial matching (`--partial` or `-p`) are mutually
exclusive. An error is displayed when used simultaneously.

#### `refute_line`

Similarly to `refute_output`, this function helps to verify that a
command or function produces the correct output. It checks that the
unexpected line does not appear in the output (default) or in a specific
line of it. Matching can be literal (default), partial or regular
expression. This function is the logical complement of `assert_line`.

***Warning:*** *Due to a [bug in Bats][bats-93], empty lines are
discarded from `${lines[@]}`, causing line indices to change and
preventing testing for empty lines.*

[bats-93]: https://github.com/sstephenson/bats/pull/93

##### Looking for a line in the output

By default, the entire output is searched for the unexpected line. The
assertion fails if the unexpected line is found in `${lines[@]}`.

```bash
@test 'refute_line() looking for line' {
  run echo $'have-0\nwant\nhave-2'
  refute_line 'want'
}
```

On failure, the unexpected line, the index of its first match and the
output with the matching line highlighted are displayed.

***Warning:*** *The output displayed does not contain empty lines. See
the Warning above for more.*

```
-- line should not be in output --
line  : want
index : 1
output (3 lines):
  have-0
> want
  have-2
--
```

If output is not longer than one line, it is displayed in *two-column*
format.

##### Matching a specific line

When the `--index <idx>` option is used (`-n <idx>` for short) , the
unexpected line is matched only against the line identified by the given
index. The assertion fails if the unexpected line equals
`${lines[<idx>]}`.

```bash
@test 'refute_line() specific line' {
  run echo $'have-0\nwant-1\nhave-2'
  refute_line --index 1 'want-1'
}
```

On failure, the index and the unexpected line are displayed.

```
-- line should differ --
index : 1
line  : want-1
--
```

##### Partial matching

Partial matching can be enabled with the `--partial` option (`-p` for
short). When used, a match fails if the unexpected *substring* is found
in the matched line.

```bash
@test 'refute_line() partial matching' {
  run echo $'have 1\nwant 2\nhave 3'
  refute_line --partial 'want'
}
```

On failure, in addition to the details of literal matching, the
substring is also displayed. When used with `--index <idx>` the
substring replaces the unexpected line.

```
-- no line should contain substring --
substring : want
index     : 1
output (3 lines):
  have 1
> want 2
  have 3
--
```

This option and regular expression matching (`--regexp` or `-e`) are
mutually exclusive. An error is displayed when used simultaneously.

##### Regular expression matching

Regular expression matching can be enabled with the `--regexp` option
(`-e` for short). When used, a match fails if the *extended regular
expression* matches the line being tested.

*Note: As expected, the anchors `^` and `$` bind to the beginning and
the end of the matched line, respectively.*

```bash
@test 'refute_line() regular expression matching' {
  run echo $'Foobar v0.1.0\nRelease date: 2015-11-29'
  refute_line --index 0 --regexp '^Foobar v[0-9]+\.[0-9]+\.[0-9]$'
}
```

On failure, in addition to the details of literal matching, the regular
expression is also displayed. When used with `--index <idx>` the regular
expression replaces the unexpected line.

```
-- regular expression should not match line --
index  : 0
regexp : ^Foobar v[0-9]+\.[0-9]+\.[0-9]$
line   : Foobar v0.1.0
--
```

An error is displayed if the specified extended regular expression is
invalid.

This option and partial matching (`--partial` or `-p`) are mutually
exclusive. An error is displayed when used simultaneously.


## Installing Bats from source

Check out a copy of the Bats repository. Then, either add the Bats
`bin` directory to your `$PATH`, or run the provided `install.sh`
command with the location to the prefix in which you want to install
Bats. For example, to install Bats into `/usr/local`,

    $ git clone https://github.com/sstephenson/bats.git
    $ cd bats
    $ ./install.sh /usr/local

Note that you may need to run `install.sh` with `sudo` if you do not
have permission to write to the installation prefix.


## Support

The Bats source code repository is [hosted on
GitHub](https://github.com/sstephenson/bats). There you can file bugs
on the issue tracker or submit tested pull requests for review.

For real-world examples from open-source projects using Bats, see
[Projects Using Bats](https://github.com/sstephenson/bats/wiki/Projects-Using-Bats)
on the wiki.

To learn how to set up your editor for Bats syntax highlighting, see
[Syntax Highlighting](https://github.com/sstephenson/bats/wiki/Syntax-Highlighting)
on the wiki.


## Version history

*0.4.0* (August 13, 2014)

* Improved the display of failing test cases. Bats now shows the
  source code of failing test lines, along with full stack traces
  including function names, filenames, and line numbers.
* Improved the display of the pretty-printed test summary line to
  include the number of skipped tests, if any.
* Improved the speed of the preprocessor, dramatically shortening test
  and suite startup times.
* Added support for absolute pathnames to the `load` helper.
* Added support for single-line `@test` definitions.
* Added bats(1) and bats(7) manual pages.
* Modified the `bats` command to default to TAP output when the `$CI`
  variable is set, to better support environments such as Travis CI.

*0.3.1* (October 28, 2013)

* Fixed an incompatibility with the pretty formatter in certain
  environments such as tmux.
* Fixed a bug where the pretty formatter would crash if the first line
  of a test file's output was invalid TAP.

*0.3.0* (October 21, 2013)

* Improved formatting for tests run from a terminal. Failing tests
  are now colored in red, and the total number of failing tests is
  displayed at the end of the test run. When Bats is not connected to
  a terminal (e.g. in CI runs), or when invoked with the `--tap` flag,
  output is displayed in standard TAP format.
* Added the ability to skip tests using the `skip` command.
* Added a message to failing test case output indicating the file and
  line number of the statement that caused the test to fail.
* Added "ad-hoc" test suite support. You can now invoke `bats` with
  multiple filename or directory arguments to run all the specified
  tests in aggregate.
* Added support for test files with Windows line endings.
* Fixed regular expression warnings from certain versions of Bash.
* Fixed a bug running tests containing lines that begin with `-e`.

*0.2.0* (November 16, 2012)

* Added test suite support. The `bats` command accepts a directory
  name containing multiple test files to be run in aggregate.
* Added the ability to count the number of test cases in a file or
  suite by passing the `-c` flag to `bats`.
* Preprocessed sources are cached between test case runs in the same
  file for better performance.

*0.1.0* (December 30, 2011)

* Initial public release.

---

© 2014 Sam Stephenson. Bats is released under an MIT-style license;
see `LICENSE` for details.
