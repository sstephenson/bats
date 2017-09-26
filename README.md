## BATS-core: Bash Automated Testing System (2017)

[![Build Status](https://travis-ci.org/bats-core/bats-core.svg?branch=master)](https://travis-ci.org/bats-core/bats-core)

### Background:
### What is this repo?
**Tuesday, September 19, 2017:** This is a mirrored fork of [bats](https://github.com/sstephenson/bats), at [0360811](https://github.com/sstephenson/bats/commit/03608115df2071fff4eaaff1605768c275e5f81f). It was created via `git clone --bare` and `git push --mirror`.

#### Why was it created?
The original bats repository needed new maintainers, and has not been actively maintained since 2013. While there were volunteers for maintainers, attempts to organize issues, and outstanding PRs, the lack of write-access to the repo hindered progress severely.

## What's the plan and why?
The rough plan, originally [outlined here](https://github.com/sstephenson/bats/issues/150#issuecomment-323845404) is to create a new, mirrored mainline (this repo!). An excerpt:

> **1. Roadmap 1.0:**
> There are already existing high-quality PRs, and often-requested features and issues, especially here at [#196](https://github.com/sstephenson/bats/issues/196). Leverage these and **consolidate into a single roadmap**.
>
>**2. Create or choose a fork or *mirror* of this repo to use as the new mainline:**
>Repoint existing PRs (whichever ones are possible) to the new mainline, get that repo to a stable 1.0. IMO we should create an organization and grant 2-3 people admin and write access.
>

Doing it this way accomplishes two things:
1. Removes the dependency on the original maintainer 
2. Enables collaboration and contribution flow again
3. Allows the possibility of merging back to original, or merging from original if or when the need arises
4. Prevents lock-out by giving administrative access to more than one person, increases transferability

## Misc
- We are `#bats` on freenode

---
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
[Bats Evaluation Process](https://github.com/bats-core/bats-core/wiki/Bats-Evaluation-Process)
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


## Installing Bats from source

Check out a copy of the Bats repository. Then, either add the Bats
`bin` directory to your `$PATH`, or run the provided `install.sh`
command with the location to the prefix in which you want to install
Bats. For example, to install Bats into `/usr/local`,

    $ git clone https://github.com/bats-core/bats-core.git
    $ cd bats-core
    $ ./install.sh /usr/local

Note that you may need to run `install.sh` with `sudo` if you do not
have permission to write to the installation prefix.


## Support

The Bats source code repository is [hosted on
GitHub](https://github.com/bats-core/bats-core). There you can file bugs
on the issue tracker or submit tested pull requests for review.

For real-world examples from open-source projects using Bats, see
[Projects Using Bats](https://github.com/bats-core/bats-core/wiki/Projects-Using-Bats)
on the wiki.

To learn how to set up your editor for Bats syntax highlighting, see
[Syntax Highlighting](https://github.com/bats-core/bats-core/wiki/Syntax-Highlighting)
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

© 2017 Bianca Tamayo (bats-core organization)

© 2014 Sam Stephenson

Bats is released under an MIT-style license;
see `LICENSE` for details.
