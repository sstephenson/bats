#!/usr/bin/env bats

load test_helper


#
# Matching entire output.
#

# Literal matching.

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

@test "refute_output() <unexpected>: displays details in multi-line format if necessary" {
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

@test 'refute_output() <unexpected>: performs literal matching by default' {
  run echo 'a'
  run refute_output '*'
  [ "$status" -eq 0 ]
}

@test 'refute_output(): reads the unexpected output from STDIN' {
  run echo 'b'
  export output
  run bash -c ". '${BATS_LIB}/batslib.bash'; echo 'a' | refute_output"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

# Partial matching: `-p <partial>'.

@test "refute_output() -p <partial>: returns 0 if <partial> is not a substring in \`\$output'" {
  run echo $'a\nb\nc'
  run refute_output -p 'd'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "refute_output() -p <partial>: returns 1 and displays details if <partial> is a substring in \`\$output'" {
  run echo 'a'
  run refute_output -p 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- output should not contain substring --' ]
  [ "${lines[1]}" == 'substring : a' ]
  [ "${lines[2]}" == 'output    : a' ]
  [ "${lines[3]}" == '--' ]
}

@test "refute_output() -p <partial>: displays details in multi-line format if necessary" {
  run echo $'a 0\na 1'
  run refute_output -p 'a'
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

# Regular expression matching: `-r <regex>'.

@test "refute_output() -r <regex>: returns 0 if <regex> does not match \`\$output'" {
  run echo $'a\nb\nc'
  run refute_output -r '.*d.*'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "refute_output() -r <regex>: returns 1 and displays details if <regex> matches \`\$output'" {
  run echo 'a'
  run refute_output -r '.*a.*'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- regular expression should not match output --' ]
  [ "${lines[1]}" == 'regex  : .*a.*' ]
  [ "${lines[2]}" == 'output : a' ]
  [ "${lines[3]}" == '--' ]
}

@test "refute_output() -r <regex>: displays details in multi-line format if necessary" {
  run echo $'a 0\na 1'
  run refute_output -r '.*a.*'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 7 ]
  [ "${lines[0]}" == '-- regular expression should not match output --' ]
  [ "${lines[1]}" == 'regex (1 lines):' ]
  [ "${lines[2]}" == '  .*a.*' ]
  [ "${lines[3]}" == 'output (2 lines):' ]
  [ "${lines[4]}" == '  a 0' ]
  [ "${lines[5]}" == '  a 1' ]
  [ "${lines[6]}" == '--' ]
}


#
# Matching a single line: `-l <index>'.
#

# Literal matching.

@test "refute_output() -l <index> <unexpected>: returns 0 if <unexpected> does not equal \`\${lines[<index>]}'" {
  run echo $'a\nb\nc'
  run refute_output -l 1 'd'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "refute_output() -l <index> <unexpected>: returns 1 and displays details if <unexpected> equals \`\${lines[<index>]}'" {
  run echo $'a\nb\nc'
  run refute_output -l 1 'b'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- line should differ --' ]
  [ "${lines[1]}" == 'index      : 1' ]
  [ "${lines[2]}" == 'unexpected : b' ]
  [ "${lines[3]}" == '--' ]
}

@test 'refute_output() -l <index> <unexpected>: performs literal matching by default' {
  run echo $'a\nb\nc'
  run refute_output -l 1 '*'
  [ "$status" -eq 0 ]
}

@test 'refute_output() -l: without <index> returns 1 and displays an error message' {
  run echo $'a\nb\nc'
  run refute_output -l 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- ERROR: refute_output --' ]
  [ "${lines[1]}" == "\`-l' requires an integer argument" ]
  [ "${lines[2]}" == '--' ]
}

# Partial matching: `-p <partial>'.

@test "refute_output() -l <index> -p <partial>: returns 0 if <partial> is not a substring in \`\${lines[<index>]}'" {
  run echo $'a\nabc\nc'
  run refute_output -l 1 -p 'd'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "refute_output() -l <index> -p <partial>: returns 1 and displays details if <partial> is a substring in \`\${lines[<index>]}'" {
  run echo $'a\nabc\nc'
  run refute_output -l 1 -p 'b'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ "${lines[0]}" == '-- line should not contain substring --' ]
  [ "${lines[1]}" == 'index     : 1' ]
  [ "${lines[2]}" == 'substring : b' ]
  [ "${lines[3]}" == 'line      : abc' ]
  [ "${lines[4]}" == '--' ]
}

# Regular expression matching: `-r <regex>'.

@test "refute_output() -l <index> -r <regex>: returns 0 if <regex> does not match \`\${lines[<index>]}'" {
  run echo $'a\nabc\nc'
  run refute_output -l 1 -r '.*d.*'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "refute_output() -l <index> -r <regex>: returns 1 and displays details if <regex> matches \`\${lines[<index>]}'" {
  run echo $'a\nabc\nc'
  run refute_output -l 1 -r '.*b.*'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ "${lines[0]}" == '-- regular expression should not match line --' ]
  [ "${lines[1]}" == 'index : 1' ]
  [ "${lines[2]}" == 'regex : .*b.*' ]
  [ "${lines[3]}" == 'line  : abc' ]
  [ "${lines[4]}" == '--' ]
}


#
# Containing a line: `-L'.
#

# Literal matching.

@test "refute_output() -L <unexpected>: returns 0 if <unexpected> is not a line in \`\${lines[@]}'" {
  run echo $'a\nb\nc'
  run refute_output -L 'd'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "refute_output() -L <unexpected>: returns 1 and displays details if <unexpected> is not a line in \`\${lines[@]}'" {
  run echo 'a'
  run refute_output -L 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ "${lines[0]}" == '-- line should not be in output --' ]
  [ "${lines[1]}" == 'line   : a' ]
  [ "${lines[2]}" == 'index  : 0' ]
  [ "${lines[3]}" == 'output : a' ]
  [ "${lines[4]}" == '--' ]
}

@test "refute_output() -L <unexpected>: displays details in multi-line format if necessary" {
  run echo $'a\nb\nc'
  run refute_output -L 'b'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 8 ]
  [ "${lines[0]}" == '-- line should not be in output --' ]
  [ "${lines[1]}" == 'line  : b' ]
  [ "${lines[2]}" == 'index : 1' ]
  [ "${lines[3]}" == 'output (3 lines):' ]
  [ "${lines[4]}" == '  a' ]
  [ "${lines[5]}" == '> b' ]
  [ "${lines[6]}" == '  c' ]
  [ "${lines[7]}" == '--' ]
}

@test 'refute_output() -L <unexpected>: performs literal matching by default' {
  run echo 'a'
  run refute_output -L '*'
  [ "$status" -eq 0 ]
}

# Partial matching: `-p <partial>'.

@test "refute_output() -L -p <partial>: returns 0 if <partial> is not a substring in any line in \`\${lines[@]}'" {
  run echo $'a\nb\nc'
  run refute_output -L -p 'd'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "refute_output() -L -p <partial>: returns 1 and displays details if <partial> is a substring in at least one line in \`\${lines[@]}'" {
  run echo 'a'
  run refute_output -L -p 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ "${lines[0]}" == '-- no line should contain substring --' ]
  [ "${lines[1]}" == 'substring : a' ]
  [ "${lines[2]}" == 'index     : 0' ]
  [ "${lines[3]}" == 'output    : a' ]
  [ "${lines[4]}" == '--' ]
}

@test "refute_output() -L -p <partial>: displays details in multi-line format if necessary" {
  run echo $'a\nabc\nc'
  run refute_output -L -p 'b'
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

# Regular expression matching: `-r <regex>'.

@test "refute_output() -L -r <regex>: returns 0 if <regex> does not match any line in \`\${lines[@]}'" {
  run echo $'a\nb\nc'
  run refute_output -L -r '.*d.*'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "refute_output() -L -r <regex>: returns 1 and displays details if <regex> matches any lines in \`\${lines[@]}'" {
  run echo 'a'
  run refute_output -L -r '.*a.*'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ "${lines[0]}" == '-- no line should match the regular expression --' ]
  [ "${lines[1]}" == 'regex  : .*a.*' ]
  [ "${lines[2]}" == 'index  : 0' ]
  [ "${lines[3]}" == 'output : a' ]
  [ "${lines[4]}" == '--' ]
}

@test 'refute_output() -L -r <regex>: displays details in multi-line format if necessary' {
  run echo $'a\nabc\nc'
  run refute_output -L -r '.*b.*'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 8 ]
  [ "${lines[0]}" == '-- no line should match the regular expression --' ]
  [ "${lines[1]}" == 'regex : .*b.*' ]
  [ "${lines[2]}" == 'index : 1' ]
  [ "${lines[3]}" == 'output (3 lines):' ]
  [ "${lines[4]}" == '  a' ]
  [ "${lines[5]}" == '> abc' ]
  [ "${lines[6]}" == '  c' ]
  [ "${lines[7]}" == '--' ]
}


#
# Common.
#

@test 'refute_output() -l and -L are mutually exclusive' {
  run refute_output -l 1 -L 'b'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- ERROR: refute_output --' ]
  [ "${lines[1]}" == "\`-l' and \`-L' are mutually exclusive" ]
  [ "${lines[2]}" == '--' ]
}

@test 'refute_output() -p and -r are mutually exclusive' {
  run refute_output -p -r 'b'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- ERROR: refute_output --' ]
  [ "${lines[1]}" == "\`-p' and \`-r' are mutually exclusive" ]
  [ "${lines[2]}" == '--' ]
}

@test "refute_output() -r <regex>: returns 1 and displays an error message if <regex> is not a valid extended regular expression" {
  run refute_output -r '[.*'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- ERROR: refute_output --' ]
  [ "${lines[1]}" == "Invalid extended regular expression: \`[.*'" ]
  [ "${lines[2]}" == '--' ]
}
