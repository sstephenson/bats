
@test "test diag" {
  diag "Foo"
}

@test "test diag fail" {
  diag "...."
  fail "Reasons"
}

@test "test diag todo" {
  diag "...."
  TODO "Foo"
}

@test "test diag skip" {
  diag "...."
  skip "Foo"
}

