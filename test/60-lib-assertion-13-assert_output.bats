#!/usr/bin/env bats

load test_helper


#
# Matching entire output.
#

# Literal matching.

@test "assert_output() <expected>: returns 0 if <expected> equals \`\$output'" {
  run echo 'a'
  run assert_output 'a'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "assert_output() <expected>: returns 1 and displays details if <expected> does not equal \`\$output'" {
  run echo 'b'
  run assert_output 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- output differs --' ]
  [ "${lines[1]}" == 'expected : a' ]
  [ "${lines[2]}" == 'actual   : b' ]
  [ "${lines[3]}" == '--' ]
}

@test "assert_output() <expected>: displays details in multi-line format if \`\$output' is longer than one line" {
  run echo $'b 0\nb 1'
  run assert_output 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 7 ]
  [ "${lines[0]}" == '-- output differs --' ]
  [ "${lines[1]}" == 'expected (1 lines):' ]
  [ "${lines[2]}" == '  a' ]
  [ "${lines[3]}" == 'actual (2 lines):' ]
  [ "${lines[4]}" == '  b 0' ]
  [ "${lines[5]}" == '  b 1' ]
  [ "${lines[6]}" == '--' ]
}

@test "assert_output() <expected>: displays details in multi-line format if <expected> is longer than one line" {
  run echo 'b'
  run assert_output $'a 0\na 1'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 7 ]
  [ "${lines[0]}" == '-- output differs --' ]
  [ "${lines[1]}" == 'expected (2 lines):' ]
  [ "${lines[2]}" == '  a 0' ]
  [ "${lines[3]}" == '  a 1' ]
  [ "${lines[4]}" == 'actual (1 lines):' ]
  [ "${lines[5]}" == '  b' ]
  [ "${lines[6]}" == '--' ]
}

@test 'assert_output() <expected>: performs literal matching by default' {
  run echo 'a'
  run assert_output '*'
  [ "$status" -eq 1 ]
}

@test 'assert_output(): reads the expected output from STDIN' {
  run echo 'a'
  export output
  run bash -c ". '${BATS_LIB}/batslib.bash'; echo 'a' | assert_output"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

# Partial matching: `-p <partial>'.

@test "assert_output() -p <partial>: returns 0 if <partial> is a substring in \`\$output'" {
  run echo $'a\nb\nc'
  run assert_output -p 'b'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "assert_output() -p <partial>: returns 1 and displays details if <partial> is not a substring in \`\$output'" {
  run echo 'b'
  run assert_output -p 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- output does not contain substring --' ]
  [ "${lines[1]}" == 'substring : a' ]
  [ "${lines[2]}" == 'output    : b' ]
  [ "${lines[3]}" == '--' ]
}

@test "assert_output() -p <partial>: displays details in multi-line format if \`\$output' is longer than one line" {
  run echo $'b 0\nb 1'
  run assert_output -p 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 7 ]
  [ "${lines[0]}" == '-- output does not contain substring --' ]
  [ "${lines[1]}" == 'substring (1 lines):' ]
  [ "${lines[2]}" == '  a' ]
  [ "${lines[3]}" == 'output (2 lines):' ]
  [ "${lines[4]}" == '  b 0' ]
  [ "${lines[5]}" == '  b 1' ]
  [ "${lines[6]}" == '--' ]
}

@test 'assert_output() -p <partial>: displays details in multi-line format if <partial> is longer than one line' {
  run echo 'b'
  run assert_output -p $'a 0\na 1'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 7 ]
  [ "${lines[0]}" == '-- output does not contain substring --' ]
  [ "${lines[1]}" == 'substring (2 lines):' ]
  [ "${lines[2]}" == '  a 0' ]
  [ "${lines[3]}" == '  a 1' ]
  [ "${lines[4]}" == 'output (1 lines):' ]
  [ "${lines[5]}" == '  b' ]
  [ "${lines[6]}" == '--' ]
}

# Regular expression matching: `-r <regex>'.

@test "assert_output() -r <regex>: returns 0 if <regex> matches \`\$output'" {
  run echo $'a\nb\nc'
  run assert_output -r '.*b.*'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "assert_output() -r <regex>: returns 1 and displays details if <regex> does not match \`\$output'" {
  run echo 'b'
  run assert_output -r '.*a.*'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- regular expression does not match output --' ]
  [ "${lines[1]}" == 'regex  : .*a.*' ]
  [ "${lines[2]}" == 'output : b' ]
  [ "${lines[3]}" == '--' ]
}

@test "assert_output() -r <regex>: displays details in multi-line format if \`\$output' is longer than one line" {
  run echo $'b 0\nb 1'
  run assert_output -r '.*a.*'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 7 ]
  [ "${lines[0]}" == '-- regular expression does not match output --' ]
  [ "${lines[1]}" == 'regex (1 lines):' ]
  [ "${lines[2]}" == '  .*a.*' ]
  [ "${lines[3]}" == 'output (2 lines):' ]
  [ "${lines[4]}" == '  b 0' ]
  [ "${lines[5]}" == '  b 1' ]
  [ "${lines[6]}" == '--' ]
}

@test "assert_output() -r <regex>: displays details in multi-line format if <regex> is longer than one line" {
  run echo 'b'
  run assert_output -r $'.*a\nb.*'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 7 ]
  [ "${lines[0]}" == '-- regular expression does not match output --' ]
  [ "${lines[1]}" == 'regex (2 lines):' ]
  [ "${lines[2]}" == '  .*a' ]
  [ "${lines[3]}" == '  b.*' ]
  [ "${lines[4]}" == 'output (1 lines):' ]
  [ "${lines[5]}" == '  b' ]
  [ "${lines[6]}" == '--' ]
}


#
# Matching a single line: `-l <index>'.
#

# Literal matching.

@test "assert_output() -l <index> <expected>: returns 0 if <expected> equals \`\${lines[<index>]}'" {
  run echo $'a\nb\nc'
  run assert_output -l 1 'b'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "assert_output() -l <index> <expected>: returns 1 and displays details if <expected> does not equal \`\${lines[<index>]}'" {
  run echo $'a\nb\nc'
  run assert_output -l 1 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ "${lines[0]}" == '-- line differs --' ]
  [ "${lines[1]}" == 'index    : 1' ]
  [ "${lines[2]}" == 'expected : a' ]
  [ "${lines[3]}" == 'actual   : b' ]
  [ "${lines[4]}" == '--' ]
}

@test 'assert_output() -l <index> <expected>: performs literal matching by default' {
  run echo $'a\nb\nc'
  run assert_output -l 1 '*'
  [ "$status" -eq 1 ]
}

@test 'assert_output() -l: without <index> returns 1 and displays an error message' {
  run echo $'a\nb\nc'
  run assert_output -l 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- ERROR: assert_output --' ]
  [ "${lines[1]}" == "\`-l' requires an integer argument" ]
  [ "${lines[2]}" == '--' ]
}

# Partial matching: `-p <partial>'.

@test "assert_output() -l <index> -p <partial>: returns 0 if <partial> is a substring in \`\${lines[<index>]}'" {
  run echo $'a\nabc\nc'
  run assert_output -l 1 -p 'b'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "assert_output() -l <index> -p <partial>: returns 1 and displays details if <partial> is not a substring in \`\${lines[<index>]}'" {
  run echo $'b 0\nb 1'
  run assert_output -l 1 -p 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ "${lines[0]}" == '-- line does not contain substring --' ]
  [ "${lines[1]}" == 'index     : 1' ]
  [ "${lines[2]}" == 'substring : a' ]
  [ "${lines[3]}" == 'line      : b 1' ]
  [ "${lines[4]}" == '--' ]
}

# Regular expression matching: `-r <regex>'.

@test "assert_output() -l <index> -r <regex>: returns 0 if <regex> matches \`\${lines[<index>]}'" {
  run echo $'a\nabc\nc'
  run assert_output -l 1 -r '.*b.*'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "assert_output() -l <index> -r <regex>: returns 1 and displays details if <regex> does not match \`\${lines[<index>]}'" {
  run echo $'a\nb\nc'
  run assert_output -l 1 -r '.*a.*'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ "${lines[0]}" == '-- regular expression does not match line --' ]
  [ "${lines[1]}" == 'index : 1' ]
  [ "${lines[2]}" == 'regex : .*a.*' ]
  [ "${lines[3]}" == 'line  : b' ]
  [ "${lines[4]}" == '--' ]
}


#
# Containing a line: `-L'.
#

# Literal matching.

@test "assert_output() -L <expected>: returns 0 if <expected> is a line in \`\${lines[@]}'" {
  run echo $'a\nb\nc'
  run assert_output -L 'b'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "assert_output() -L <expected>: returns 1 and displays details if <expected> is not a line in \`\${lines[@]}'" {
  run echo 'b'
  run assert_output -L 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- output does not contain line --' ]
  [ "${lines[1]}" == 'line   : a' ]
  [ "${lines[2]}" == 'output : b' ]
  [ "${lines[3]}" == '--' ]
}

@test "assert_output() -L <expected>: displays \`\$output' in multi-line format if necessary" {
  run echo $'b 0\nb 1'
  run assert_output -L 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 6 ]
  [ "${lines[0]}" == '-- output does not contain line --' ]
  [ "${lines[1]}" == 'line : a' ]
  [ "${lines[2]}" == 'output (2 lines):' ]
  [ "${lines[3]}" == '  b 0' ]
  [ "${lines[4]}" == '  b 1' ]
  [ "${lines[5]}" == '--' ]
}

@test 'assert_output() -L <expected>: performs literal matching by default' {
  run echo 'a'
  run assert_output -L '*'
  [ "$status" -eq 1 ]
}

# Partial matching: `-p <partial>'.

@test "assert_output() -L -p <partial>: returns 0 if <partial> is a substring in at least one line in \`\${lines[@]}'" {
  run echo $'a\nabc\nc'
  run assert_output -L -p 'b'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "assert_output() -L -p <partial>: returns 1 and displays details if <partial> is not a substring in any line in \`\${lines[@]}'" {
  run echo 'b'
  run assert_output -L -p 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- no output line contains substring --' ]
  [ "${lines[1]}" == 'substring : a' ]
  [ "${lines[2]}" == 'output    : b' ]
  [ "${lines[3]}" == '--' ]
}

@test "assert_output() -L -p <partial>: displays details in multi-line format if necessary" {
  run echo $'b 0\nb 1'
  run assert_output -L -p 'a'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 6 ]
  [ "${lines[0]}" == '-- no output line contains substring --' ]
  [ "${lines[1]}" == 'substring : a' ]
  [ "${lines[2]}" == 'output (2 lines):' ]
  [ "${lines[3]}" == '  b 0' ]
  [ "${lines[4]}" == '  b 1' ]
  [ "${lines[5]}" == '--' ]
}

# Regular expression matching: `-r <regex>'.

@test "assert_output() -L -r <regex>: returns 0 if <regex> matches any line in \`\${lines[@]}'" {
  run echo $'a\nb\nc'
  run assert_output -L -r '.*b.*'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "assert_output() -L -r <regex>: returns 1 and displays details if <regex> does not match any lines in \`\${lines[@]}'" {
  run echo 'b'
  run assert_output -L -r '.*a.*'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- no output line matches regular expression --' ]
  [ "${lines[1]}" == 'regex  : .*a.*' ]
  [ "${lines[2]}" == 'output : b' ]
  [ "${lines[3]}" == '--' ]
}

@test 'assert_output() -L -r <regex>: displays details in multi-line format if necessary' {
  run echo $'b 0\nb 1'
  run assert_output -L -r '.*a.*'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 6 ]
  [ "${lines[0]}" == '-- no output line matches regular expression --' ]
  [ "${lines[1]}" == 'regex : .*a.*' ]
  [ "${lines[2]}" == 'output (2 lines):' ]
  [ "${lines[3]}" == '  b 0' ]
  [ "${lines[4]}" == '  b 1' ]
  [ "${lines[5]}" == '--' ]
}


#
# Common.
#

@test 'assert_output() -l and -L are mutually exclusive' {
  run assert_output -l 1 -L 'b'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- ERROR: assert_output --' ]
  [ "${lines[1]}" == "\`-l' and \`-L' are mutually exclusive" ]
  [ "${lines[2]}" == '--' ]
}

@test 'assert_output() -p and -r are mutually exclusive' {
  run assert_output -p -r 'b'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- ERROR: assert_output --' ]
  [ "${lines[1]}" == "\`-p' and \`-r' are mutually exclusive" ]
  [ "${lines[2]}" == '--' ]
}

@test "assert_output() -r <regex>: returns 1 and displays an error message if <regex> is not a valid extended regular expression" {
  run assert_output -r '[.*'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- ERROR: assert_output --' ]
  [ "${lines[1]}" == "Invalid extended regular expression: \`[.*'" ]
  [ "${lines[2]}" == '--' ]
}
