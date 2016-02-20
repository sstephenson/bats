#!/usr/bin/env bats

load test_helper


###############################################################################
# Containing a line
###############################################################################

#
# Literal matching
#

# Correctness
@test "refute_line() <unexpected>: returns 0 if <unexpected> is not a line in \`\${lines[@]}'" {
  run echo $'a\nb\nc'
  run refute_line 'd'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "refute_line() <unexpected>: returns 1 and displays details if <unexpected> is not a line in \`\${lines[@]}'" {
  run echo 'a'
  run refute_line 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ "${lines[0]}" == '-- line should not be in output --' ]
  [ "${lines[1]}" == 'line   : a' ]
  [ "${lines[2]}" == 'index  : 0' ]
  [ "${lines[3]}" == 'output : a' ]
  [ "${lines[4]}" == '--' ]
}

# Output formatting
@test "refute_line() <unexpected>: displays \`\$output' in multi-line format if it is longer than one line" {
  run echo $'a 0\na 1\na 2'
  run refute_line 'a 1'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 8 ]
  [ "${lines[0]}" == '-- line should not be in output --' ]
  [ "${lines[1]}" == 'line  : a 1' ]
  [ "${lines[2]}" == 'index : 1' ]
  [ "${lines[3]}" == 'output (3 lines):' ]
  [ "${lines[4]}" == '  a 0' ]
  [ "${lines[5]}" == '> a 1' ]
  [ "${lines[6]}" == '  a 2' ]
  [ "${lines[7]}" == '--' ]
}

# Options
@test 'refute_line() <unexpected>: performs literal matching by default' {
  run echo 'a'
  run refute_line '*'
  [ "$status" -eq 0 ]
}


#
# Partial matching: `-p' and `--partial'
#

# Options
test_p_partial () {
  run echo $'a\nb\nc'
  run refute_line "$1" 'd'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'refute_line() -p <partial>: enables partial matching' {
  test_p_partial -p
}

@test 'refute_line() --partial <partial>: enables partial matching' {
  test_p_partial --partial
}

# Correctness
@test "refute_line() --partial <partial>: returns 0 if <partial> is not a substring in any line in \`\${lines[@]}'" {
  run echo $'a\nb\nc'
  run refute_line --partial 'd'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "refute_line() --partial <partial>: returns 1 and displays details if <partial> is a substring in any line in \`\${lines[@]}'" {
  run echo 'a'
  run refute_line --partial 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ "${lines[0]}" == '-- no line should contain substring --' ]
  [ "${lines[1]}" == 'substring : a' ]
  [ "${lines[2]}" == 'index     : 0' ]
  [ "${lines[3]}" == 'output    : a' ]
  [ "${lines[4]}" == '--' ]
}

# Output formatting
@test "refute_line() --partial <partial>: displays \`\$output' in multi-line format if it is longer than one line" {
  run echo $'a\nabc\nc'
  run refute_line --partial 'b'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 8 ]
  [ "${lines[0]}" == '-- no line should contain substring --' ]
  [ "${lines[1]}" == 'substring : b' ]
  [ "${lines[2]}" == 'index     : 1' ]
  [ "${lines[3]}" == 'output (3 lines):' ]
  [ "${lines[4]}" == '  a' ]
  [ "${lines[5]}" == '> abc' ]
  [ "${lines[6]}" == '  c' ]
  [ "${lines[7]}" == '--' ]
}


#
# Regular expression matching: `-e' and `--regexp'
#

# Options
test_r_regexp () {
  run echo $'a\nb\nc'
  run refute_line "$1" '^.d'
  echo "$output"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'refute_line() -e <regexp>: enables regular expression matching' {
  test_r_regexp -e
}

@test 'refute_line() --regexp <regexp>: enables regular expression matching' {
  test_r_regexp --regexp
}

# Correctness
@test "refute_line() --regexp <regexp>: returns 0 if <regexp> does not match any line in \`\${lines[@]}'" {
  run echo $'a\nb\nc'
  run refute_line --regexp '.*d.*'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "refute_line() --regexp <regexp>: returns 1 and displays details if <regexp> matches any lines in \`\${lines[@]}'" {
  run echo 'a'
  run refute_line --regexp '.*a.*'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ "${lines[0]}" == '-- no line should match the regular expression --' ]
  [ "${lines[1]}" == 'regexp : .*a.*' ]
  [ "${lines[2]}" == 'index  : 0' ]
  [ "${lines[3]}" == 'output : a' ]
  [ "${lines[4]}" == '--' ]
}

# Output formatting
@test "refute_line() --regexp <regexp>: displays \`\$output' in multi-line format if longer than one line" {
  run echo $'a\nabc\nc'
  run refute_line --regexp '.*b.*'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 8 ]
  [ "${lines[0]}" == '-- no line should match the regular expression --' ]
  [ "${lines[1]}" == 'regexp : .*b.*' ]
  [ "${lines[2]}" == 'index  : 1' ]
  [ "${lines[3]}" == 'output (3 lines):' ]
  [ "${lines[4]}" == '  a' ]
  [ "${lines[5]}" == '> abc' ]
  [ "${lines[6]}" == '  c' ]
  [ "${lines[7]}" == '--' ]
}


###############################################################################
# Matching single line: `-n' and `--index'
###############################################################################

# Options
test_n_index () {
  run echo $'a\nb\nc'
  run refute_line "$1" 1 'd'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'refute_line() -n <idx> <expected>: matches against the <idx>-th line only' {
  test_n_index -n
}

@test 'refute_line() --index <idx> <expected>: matches against the <idx>-th line only' {
  test_n_index --index
}

@test 'refute_line() --index <idx>: returns 1 and displays an error message if <idx> is not an integer' {
  run refute_line --index 1a
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- ERROR: refute_line --' ]
  [ "${lines[1]}" == "\`--index' requires an integer argument: \`1a'" ]
  [ "${lines[2]}" == '--' ]
}


#
# Literal matching
#

# Correctness
@test "refute_line() --index <idx> <unexpected>: returns 0 if <unexpected> does not equal \`\${lines[<idx>]}'" {
  run echo $'a\nb\nc'
  run refute_line --index 1 'd'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "refute_line() --index <idx> <unexpected>: returns 1 and displays details if <unexpected> equals \`\${lines[<idx>]}'" {
  run echo $'a\nb\nc'
  run refute_line --index 1 'b'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- line should differ --' ]
  [ "${lines[1]}" == 'index : 1' ]
  [ "${lines[2]}" == 'line  : b' ]
  [ "${lines[3]}" == '--' ]
}

# Options
@test 'refute_line() --index <idx> <unexpected>: performs literal matching by default' {
  run echo $'a\nb\nc'
  run refute_line --index 1 '*'
  [ "$status" -eq 0 ]
}


#
# Partial matching: `-p' and `--partial'
#

# Options
test_index_p_partial () {
  run echo $'a\nb\nc'
  run refute_line --index 1 "$1" 'd'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'refute_line() --index <idx> -p <partial>: enables partial matching' {
  test_index_p_partial -p
}

@test 'refute_line() --index <idx> --partial <partial>: enables partial matching' {
  test_index_p_partial --partial
}

# Correctness
@test "refute_line() --index <idx> --partial <partial>: returns 0 if <partial> is not a substring in \`\${lines[<idx>]}'" {
  run echo $'a\nabc\nc'
  run refute_line --index 1 --partial 'd'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "refute_line() --index <idx> --partial <partial>: returns 1 and displays details if <partial> is a substring in \`\${lines[<idx>]}'" {
  run echo $'a\nabc\nc'
  run refute_line --index 1 --partial 'b'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ "${lines[0]}" == '-- line should not contain substring --' ]
  [ "${lines[1]}" == 'index     : 1' ]
  [ "${lines[2]}" == 'substring : b' ]
  [ "${lines[3]}" == 'line      : abc' ]
  [ "${lines[4]}" == '--' ]
}


#
# Regular expression matching: `-e' and `--regexp'
#

# Options
test_index_r_regexp () {
  run echo $'a\nb\nc'
  run refute_line --index 1 "$1" '^.b'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'refute_line() --index <idx> -e <regexp>: enables regular expression matching' {
  test_index_r_regexp -e
}

@test 'refute_line() --index <idx> --regexp <regexp>: enables regular expression matching' {
  test_index_r_regexp --regexp
}

# Correctness
@test "refute_line() --index <idx> --regexp <regexp>: returns 0 if <regexp> does not match \`\${lines[<idx>]}'" {
  run echo $'a\nabc\nc'
  run refute_line --index 1 --regexp '.*d.*'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "refute_line() --index <idx> --regexp <regexp>: returns 1 and displays details if <regexp> matches \`\${lines[<idx>]}'" {
  run echo $'a\nabc\nc'
  run refute_line --index 1 --regexp '.*b.*'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ "${lines[0]}" == '-- regular expression should not match line --' ]
  [ "${lines[1]}" == 'index  : 1' ]
  [ "${lines[2]}" == 'regexp : .*b.*' ]
  [ "${lines[3]}" == 'line   : abc' ]
  [ "${lines[4]}" == '--' ]
}


###############################################################################
# Common
###############################################################################

@test "refute_line(): \`--partial' and \`--regexp' are mutually exclusive" {
  run refute_line --partial --regexp
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- ERROR: refute_line --' ]
  [ "${lines[1]}" == "\`--partial' and \`--regexp' are mutually exclusive" ]
  [ "${lines[2]}" == '--' ]
}

@test 'refute_line() --regexp <regexp>: returns 1 and displays an error message if <regexp> is not a valid extended regular expression' {
  run refute_line --regexp '[.*'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- ERROR: refute_line --' ]
  [ "${lines[1]}" == "Invalid extended regular expression: \`[.*'" ]
  [ "${lines[2]}" == '--' ]
}
