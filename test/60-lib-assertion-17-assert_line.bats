#!/usr/bin/env bats

load test_helper


###############################################################################
# Containing a line
###############################################################################

#
# Literal matching
#

# Correctness
@test "assert_line() <expected>: returns 0 if <expected> is a line in \`\${lines[@]}'" {
  run echo $'a\nb\nc'
  run assert_line 'b'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "assert_line() <expected>: returns 1 and displays details if <expected> is not a line in \`\${lines[@]}'" {
  run echo 'b'
  run assert_line 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- output does not contain line --' ]
  [ "${lines[1]}" == 'line   : a' ]
  [ "${lines[2]}" == 'output : b' ]
  [ "${lines[3]}" == '--' ]
}

# Output formatting
@test "assert_line() <expected>: displays \`\$output' in multi-line format if it is longer than one line" {
  run echo $'b 0\nb 1'
  run assert_line 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 6 ]
  [ "${lines[0]}" == '-- output does not contain line --' ]
  [ "${lines[1]}" == 'line : a' ]
  [ "${lines[2]}" == 'output (2 lines):' ]
  [ "${lines[3]}" == '  b 0' ]
  [ "${lines[4]}" == '  b 1' ]
  [ "${lines[5]}" == '--' ]
}

# Options
@test 'assert_line() <expected>: performs literal matching by default' {
  run echo 'a'
  run assert_line '*'
  [ "$status" -eq 1 ]
}


#
# Partial matching: `-p' and `--partial'
#

# Options
test_p_partial () {
  run echo $'a\n_b_\nc'
  run assert_line "$1" 'b'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_line() -p <partial>: enables partial matching' {
  test_p_partial -p
}

@test 'assert_line() --partial <partial>: enables partial matching' {
  test_p_partial --partial
}

# Correctness
@test "assert_line() --partial <partial>: returns 0 if <partial> is a substring in any line in \`\${lines[@]}'" {
  run echo $'a\n_b_\nc'
  run assert_line --partial 'b'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "assert_line() --partial <partial>: returns 1 and displays details if <partial> is not a substring in any lines in \`\${lines[@]}'" {
  run echo 'b'
  run assert_line --partial 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- no output line contains substring --' ]
  [ "${lines[1]}" == 'substring : a' ]
  [ "${lines[2]}" == 'output    : b' ]
  [ "${lines[3]}" == '--' ]
}

# Output formatting
@test "assert_line() --partial <partial>: displays \`\$output' in multi-line format if it is longer than one line" {
  run echo $'b 0\nb 1'
  run assert_line --partial 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 6 ]
  [ "${lines[0]}" == '-- no output line contains substring --' ]
  [ "${lines[1]}" == 'substring : a' ]
  [ "${lines[2]}" == 'output (2 lines):' ]
  [ "${lines[3]}" == '  b 0' ]
  [ "${lines[4]}" == '  b 1' ]
  [ "${lines[5]}" == '--' ]
}


#
# Regular expression matching: `-e' and `--regexp'
#

# Options
test_r_regexp () {
  run echo $'a\n_b_\nc'
  run assert_line "$1" '^.b'
  echo "$output"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_line() -e <regexp>: enables regular expression matching' {
  test_r_regexp -e
}

@test 'assert_line() --regexp <regexp>: enables regular expression matching' {
  test_r_regexp --regexp
}

# Correctness
@test "assert_line() --regexp <regexp>: returns 0 if <regexp> matches any line in \`\${lines[@]}'" {
  run echo $'a\n_b_\nc'
  run assert_line --regexp '^.b'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "assert_line() --regexp <regexp>: returns 1 and displays details if <regexp> does not match any lines in \`\${lines[@]}'" {
  run echo 'b'
  run assert_line --regexp '^.a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- no output line matches regular expression --' ]
  [ "${lines[1]}" == 'regexp : ^.a' ]
  [ "${lines[2]}" == 'output : b' ]
  [ "${lines[3]}" == '--' ]
}

# Output formatting
@test "assert_line() --regexp <regexp>: displays \`\$output' in multi-line format if longer than one line" {
  run echo $'b 0\nb 1'
  run assert_line --regexp '^.a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 6 ]
  [ "${lines[0]}" == '-- no output line matches regular expression --' ]
  [ "${lines[1]}" == 'regexp : ^.a' ]
  [ "${lines[2]}" == 'output (2 lines):' ]
  [ "${lines[3]}" == '  b 0' ]
  [ "${lines[4]}" == '  b 1' ]
  [ "${lines[5]}" == '--' ]
}


###############################################################################
# Matching single line: `-n' and `--index'
###############################################################################

# Options
test_n_index () {
  run echo $'a\nb\nc'
  run assert_line "$1" 1 'b'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_line() -n <idx> <expected>: matches against the <idx>-th line only' {
  test_n_index -n
}

@test 'assert_line() --index <idx> <expected>: matches against the <idx>-th line only' {
  test_n_index --index
}

@test 'assert_line() --index <idx>: returns 1 and displays an error message if <idx> is not an integer' {
  run assert_line --index 1a
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- ERROR: assert_line --' ]
  [ "${lines[1]}" == "\`--index' requires an integer argument: \`1a'" ]
  [ "${lines[2]}" == '--' ]
}


#
# Literal matching
#

# Correctness
@test "assert_line() --index <idx> <expected>: returns 0 if <expected> equals \`\${lines[<idx>]}'" {
  run echo $'a\nb\nc'
  run assert_line --index 1 'b'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "assert_line() --index <idx> <expected>: returns 1 and displays details if <expected> does not equal \`\${lines[<idx>]}'" {
  run echo $'a\nb\nc'
  run assert_line --index 1 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ "${lines[0]}" == '-- line differs --' ]
  [ "${lines[1]}" == 'index    : 1' ]
  [ "${lines[2]}" == 'expected : a' ]
  [ "${lines[3]}" == 'actual   : b' ]
  [ "${lines[4]}" == '--' ]
}

# Options
@test 'assert_line() --index <idx> <expected>: performs literal matching by default' {
  run echo $'a\nb\nc'
  run assert_line --index 1 '*'
  [ "$status" -eq 1 ]
}


#
# Partial matching: `-p' and `--partial'
#

# Options
test_index_p_partial () {
  run echo $'a\n_b_\nc'
  run assert_line --index 1 "$1" 'b'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_line() --index <idx> -p <partial>: enables partial matching' {
  test_index_p_partial -p
}

@test 'assert_line() --index <idx> --partial <partial>: enables partial matching' {
  test_index_p_partial --partial
}

# Correctness
@test "assert_line() --index <idx> --partial <partial>: returns 0 if <partial> is a substring in \`\${lines[<idx>]}'" {
  run echo $'a\n_b_\nc'
  run assert_line --index 1 --partial 'b'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "assert_line() --index <idx> --partial <partial>: returns 1 and displays details if <partial> is not a substring in \`\${lines[<idx>]}'" {
  run echo $'b 0\nb 1'
  run assert_line --index 1 --partial 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ "${lines[0]}" == '-- line does not contain substring --' ]
  [ "${lines[1]}" == 'index     : 1' ]
  [ "${lines[2]}" == 'substring : a' ]
  [ "${lines[3]}" == 'line      : b 1' ]
  [ "${lines[4]}" == '--' ]
}


#
# Regular expression matching: `-e' and `--regexp'
#

# Options
test_index_r_regexp () {
  run echo $'a\n_b_\nc'
  run assert_line --index 1 "$1" '^.b'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_line() --index <idx> -e <regexp>: enables regular expression matching' {
  test_index_r_regexp -e
}

@test 'assert_line() --index <idx> --regexp <regexp>: enables regular expression matching' {
  test_index_r_regexp --regexp
}

# Correctness
@test "assert_line() --index <idx> --regexp <regexp>: returns 0 if <regexp> matches \`\${lines[<idx>]}'" {
  run echo $'a\n_b_\nc'
  run assert_line --index 1 --regexp '^.b'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "assert_line() --index <idx> --regexp <regexp>: returns 1 and displays details if <regexp> does not match \`\${lines[<idx>]}'" {
  run echo $'a\nb\nc'
  run assert_line --index 1 --regexp '^.a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ "${lines[0]}" == '-- regular expression does not match line --' ]
  [ "${lines[1]}" == 'index  : 1' ]
  [ "${lines[2]}" == 'regexp : ^.a' ]
  [ "${lines[3]}" == 'line   : b' ]
  [ "${lines[4]}" == '--' ]
}


###############################################################################
# Common
###############################################################################

@test "assert_line(): \`--partial' and \`--regexp' are mutually exclusive" {
  run assert_line --partial --regexp
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- ERROR: assert_line --' ]
  [ "${lines[1]}" == "\`--partial' and \`--regexp' are mutually exclusive" ]
  [ "${lines[2]}" == '--' ]
}

@test 'assert_line() --regexp <regexp>: returns 1 and displays an error message if <regexp> is not a valid extended regular expression' {
  run assert_line --regexp '[.*'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- ERROR: assert_line --' ]
  [ "${lines[1]}" == "Invalid extended regular expression: \`[.*'" ]
  [ "${lines[2]}" == '--' ]
}
