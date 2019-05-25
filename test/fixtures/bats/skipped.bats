@test "a skipped test" {
  skip
  true
}

@test "a skipped test with a reason" {
  skip "a reason"
  false
}
