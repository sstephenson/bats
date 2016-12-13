@test "success writing to stdout" {
  printf "success stdout 1\n"
  printf "success stdout 2\n"
}

@test "success writing to stderr" {
  printf "success stderr\n" >&2
}

@test "failure writing to stdout" {
  printf "failure stdout 1\n"
  printf "failure stdout 2\n"
  false
}

@test "failure writing to stderr" {
  printf "failure stderr\n" >&2
  false
}
