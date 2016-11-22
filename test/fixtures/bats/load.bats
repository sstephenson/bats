[ -n "$HELPER_NAME" ] || HELPER_NAME="test_helper.bash"
load "$HELPER_NAME"

@test "calling a loaded helper" {
  help_me
}
