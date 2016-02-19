@test "empty" { }

@test "passing" { true; }

@test "input redirection" { grep -q hello; } <<EOS
hello
EOS

@test "failing" { false; }
