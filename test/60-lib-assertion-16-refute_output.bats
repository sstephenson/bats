#!/usr/bin/env bats

load test_helper


#
# Literal matching
#

# Correctness
@test "refute_output() <unexpected>: returns 0 if <unexpected> does not equal \`\$output'" {
  run echo 'b'
  run refute_output 'a'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "refute_output() <unexpected>: returns 1 and displays details if <unexpected> equals \`\$output'" {
  run echo 'a'
  run refute_output 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- output equals, but it was expected to differ --' ]
  [ "${lines[1]}" == 'output : a' ]
  [ "${lines[2]}" == '--' ]
}

# Output formatting
@test 'refute_output() <unexpected>: displays details in multi-line format if necessary' {
  run echo $'a 0\na 1'
  run refute_output $'a 0\na 1'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ "${lines[0]}" == '-- output equals, but it was expected to differ --' ]
  [ "${lines[1]}" == 'output (2 lines):' ]
  [ "${lines[2]}" == '  a 0' ]
  [ "${lines[3]}" == '  a 1' ]
  [ "${lines[4]}" == '--' ]
}

# Options
@test 'refute_output() <unexpected>: performs literal matching by default' {
  run echo 'a'
  run refute_output '*'
  [ "$status" -eq 0 ]
}


#
# Partial matching: `-p' and `--partial'
#

# Options
test_p_partial () {
  run echo 'abc'
  run refute_output "$1" 'd'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'refute_output() -p <partial>: enables partial matching' {
  test_p_partial -p
}

@test 'refute_output() --partial <partial>: enables partial matching' {
  test_p_partial --partial
}

# Correctness
@test "refute_output() --partial <partial>: returns 0 if <partial> is not a substring in \`\$output'" {
  run echo $'a\nb\nc'
  run refute_output --partial 'd'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "refute_output() --partial <partial>: returns 1 and displays details if <partial> is a substring in \`\$output'" {
  run echo 'a'
  run refute_output --partial 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- output should not contain substring --' ]
  [ "${lines[1]}" == 'substring : a' ]
  [ "${lines[2]}" == 'output    : a' ]
  [ "${lines[3]}" == '--' ]
}

# Output formatting
@test 'refute_output() --partial <partial>: displays details in multi-line format if necessary' {
  run echo $'a 0\na 1'
  run refute_output --partial 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 7 ]
  [ "${lines[0]}" == '-- output should not contain substring --' ]
  [ "${lines[1]}" == 'substring (1 lines):' ]
  [ "${lines[2]}" == '  a' ]
  [ "${lines[3]}" == 'output (2 lines):' ]
  [ "${lines[4]}" == '  a 0' ]
  [ "${lines[5]}" == '  a 1' ]
  [ "${lines[6]}" == '--' ]
}


#
# Regular expression matching: `-e' and `--regexp'
#

# Options
test_r_regexp () {
  run echo 'abc'
  run refute_output "$1" '^d'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'refute_output() -e <regexp>: enables regular expression matching' {
  test_r_regexp -e
}

@test 'refute_output() --regexp <regexp>: enables regular expression matching' {
  test_r_regexp --regexp
}

# Correctness
@test "refute_output() --regexp <regexp>: returns 0 if <regexp> does not match \`\$output'" {
  run echo $'a\nb\nc'
  run refute_output --regexp '.*d.*'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "refute_output() --regexp <regexp>: returns 1 and displays details if <regexp> matches \`\$output'" {
  run echo 'a'
  run refute_output --regexp '.*a.*'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- regular expression should not match output --' ]
  [ "${lines[1]}" == 'regexp : .*a.*' ]
  [ "${lines[2]}" == 'output : a' ]
  [ "${lines[3]}" == '--' ]
}

# Output formatting
@test 'refute_output() --regexp <regexp>: displays details in multi-line format if necessary' {
  run echo $'a 0\na 1'
  run refute_output --regexp '.*a.*'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 7 ]
  [ "${lines[0]}" == '-- regular expression should not match output --' ]
  [ "${lines[1]}" == 'regexp (1 lines):' ]
  [ "${lines[2]}" == '  .*a.*' ]
  [ "${lines[3]}" == 'output (2 lines):' ]
  [ "${lines[4]}" == '  a 0' ]
  [ "${lines[5]}" == '  a 1' ]
  [ "${lines[6]}" == '--' ]
}

# Error handling
@test 'refute_output() --regexp <regexp>: returns 1 and displays an error message if <regexp> is not a valid extended regular expression' {
  run refute_output --regexp '[.*'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- ERROR: refute_output --' ]
  [ "${lines[1]}" == "Invalid extended regular expression: \`[.*'" ]
  [ "${lines[2]}" == '--' ]
}


#
# Common
#

@test "refute_output(): \`--partial' and \`--regexp' are mutually exclusive" {
  run refute_output --partial --regexp
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- ERROR: refute_output --' ]
  [ "${lines[1]}" == "\`--partial' and \`--regexp' are mutually exclusive" ]
  [ "${lines[2]}" == '--' ]
}
