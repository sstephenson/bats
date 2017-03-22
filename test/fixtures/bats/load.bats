[ -n "$HELPER_NAME" ] || HELPER_NAME="test_helper"
load "$HELPER_NAME"

BATS_LIB_PATH="$BATS_TEST_DIRNAME/load_path" \
    load "${HELPER_LIB_SINGLE_FILE:-single_file}"

BATS_LIB_PATH="$BATS_TEST_DIRNAME/load_path" \
    load "${HELPER_LIB_NO_LOADER:-no_loader}"

BATS_LIB_PATH="$BATS_TEST_DIRNAME/load_path" \
    load "${HELPER_LIB_WITH_LOADER:-with_loader}"

@test "calling a loaded helper" {
  help_me
}

@test "calling a library helper" {
    lib_func
}

@test "calling a helper from library without loading file" {
    no_loader
}

@test "calling a helper from library with loading file" {
    with_loader
}
