@test "bare" {
  [[ 1 = 1 ]]
}

@test "chained" {
  [[ 1 = 1 ]] || true
}

@test "if" {
  if [[ 1 = 1 ]]; then
    true
  else
    false
  fi
}
