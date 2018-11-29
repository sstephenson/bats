# see issue #89
echo_std_err() {
  echo "std output"
  (>&2 echo "err output")
  return 0
}

@test "std err" {
  run echo_std_err
  [ $status -eq 0 ]
  [ "${stdout}" = "std output" ]
  [ "${stderr}" = "err output" ]
  [ "${output}" = "std outputerr output" ]
}
