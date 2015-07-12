#
# output.bash
# -----------
#
# Private functions implementing output formatting. Used by public
# helper functions.
#

# Print an error message to the standard error. The message is specified
# either by positional parameters or on the standard input (by piping or
# redirection).
#
# Globals:
#   none
# Arguments:
#   $@ - [opt = STDIN] message to print
# Returns:
#   none
# Inputs:
#   STDIN - [opt = $@] message to print
# Outputs:
#   STDERR - error message
batslib_err() {
  { if (( $# > 0 )); then
      echo "$@"
    else
      cat -
    fi
  } >&2
}

# Counts the number of lines in the given text.
#
# TODO(ztombol): Remove this notice and fix tests after Bats merged #93!
# NOTE: Due to a bug in Bats, `batslib_count_lines "$output"' does not
#       give the same result as `${#lines[@]}' when the output contains
#       empty lines.
#       See PR #93 (https://github.com/sstephenson/bats/pull/93).
#
# Globals:
#   none
# Arguments:
#   $1 - text
# Returns:
#   none
# Outputs:
#   STDOUT - number of lines in given text
batslib_count_lines() {
  local -i n_lines=0
  local line
  while IFS='' read -r line || [[ -n $line ]]; do
    (( ++n_lines ))
  done < <(printf '%s' "$1")
  echo "$n_lines"
}

# Determine whether all parameters are single-line strings.
#
# Globals:
#   none
# Arguments:
#   $@ - strings to test
# Returns:
#   0 - all parameters are single-line strings
#   1 - otherwise
batslib_is_single_line() {
  for string in "$@"; do
    (( $(batslib_count_lines "$string") > 1 )) && return 1
  done
  return 0
}

# Determine the length of the longest key that has a single-line value.
# Useful in determining the column width for printing key-value pairs in
# a two-column format when some keys may have multi-line values and thus
# should be excluded.
#
# Globals:
#   none
# Arguments:
#   $@ - strings to test
# Returns:
#   none
# Outputs:
#   STDOUT - length of longest key
batslib_get_max_single_line_key_width() {
  local -i max_len=-1
  while (( $# != 0 )); do
    local -i key_len="${#1}"
    batslib_is_single_line "$2" && (( key_len > max_len )) && max_len="$key_len"
    shift 2
  done
  echo "$max_len"
}

# Print key-value pairs in two-column format. The first column contains
# the keys. Its width is specified with the first positional parameter,
# usually acquired using `batslib_get_max_single_line_key_width()', to
# nicely line up the values in the second column. The rest of the
# parameters are used to supply the key-value pairs. Every even-numbered
# parameter is a key and the following parameter is its value.
#
# Globals:
#   none
# Arguments:
#   $1 - column width
#   $even - key
#   $odd - value of the previous key
# Returns:
#   none
# Outputs:
#   STDOUT - key-value pairs in two-column format
batslib_print_kv_single() {
  local -ir col_width="$1"; shift
  while (( $# != 0 )); do
    printf '%-*s : %s\n' "$col_width" "$1" "$2"
    shift 2
  done
}

# Print key-value pairs in multi-line format. First, the key and the
# number of lines in the value is printed. Next, the value on a separate
# line. Every odd-numbered parameter is a key and the following
# parameters is its value.
#
# Globals:
#   none
# Arguments:
#   $odd - key
#   $even - value of the previous key
# Returns:
#   none
# Outputs:
#   STDOUT - key-value pairs in multi-line format
batslib_print_kv_multi() {
  while (( $# != 0 )); do
    printf '%s (%d lines):\n' "$1" "$( batslib_count_lines "$2" )"
    printf '%s\n' "$2"
    shift 2
  done
}

# Print all key-value pairs in either two-column or multi-line format.
# If all values are one line long, all pairs are printed in two-column
# format using `batslib_print_kv_single()'. Otherwise, they are printed
# in multi-line format using `batslib_print_kv_multi()' after each line
# of all values being prefixed with two spaces.
#
# Globals:
#   none
# Arguments:
#   $1 - column width for two-column format
#   $even - key
#   $odd - value of the previous key
# Returns:
#   none
# Outputs:
#   STDOUT - key-value pairs in two-column format, if all values are
#            single-line
#            key-value pairs in multi-line format, otherwise
batslib_print_kv_single_or_multi() {
  local -ir width="$1"; shift
  local -a pairs=( "$@" )

  local -a values=()
  local -i i
  for (( i=1; i < ${#pairs[@]}; i+=2 )); do
    values+=( "${pairs[$i]}" )
  done

  if batslib_is_single_line "${values[@]}"; then
    batslib_print_kv_single "$width" "${pairs[@]}"
  else
    local -i i
    for (( i=1; i < ${#pairs[@]}; i+=2 )); do
      pairs[$i]="$( batslib_prefix < <(printf '%s' "${pairs[$i]}") )"
    done
    batslib_print_kv_multi "${pairs[@]}"
  fi
}

# Prefix each line of the input with an arbitrary string.
#
# Globals:
#   none
# Arguments:
#   $1 - [opt = '  '] prefix string
# Returns:
#   none
# Inputs:
#   STDIN - lines to prefix
# Outputs:
#   STDOUT - prefixed lines
batslib_prefix() {
  local -r prefix="${1:-  }"
  local line
  while IFS='' read -r line || [[ -n $line ]]; do
    printf '%s%s\n' "$prefix" "$line"
  done
}

# Mark select lines of the input by overwriting their first few
# characters with an arbitrary string. Usually, the input is indented by
# spaces first using `batslib_prefix()'.
#
# Globals:
#   none
# Arguments:
#   $1 - marking string
#   $@ - zero-based indices of lines to mark
# Returns:
#   none
# Inputs:
#   STDIN - lines to work on
# Outputs:
#   STDOUT - lines after marking
batslib_mark() {
  local -r symbol="$1"; shift
  # Sort line numbers.
  set -- $( sort -nu <<< "$( printf '%d\n' "$@" )" )

  local line
  local -i idx=0
  while IFS='' read -r line || [[ -n $line ]]; do
    if (( ${1:--1} == idx )); then
      printf '%s\n' "${symbol}${line:${#symbol}}"
      shift
    else
      printf '%s\n' "$line"
    fi
    (( ++idx ))
  done
}

# Enclose the input in header and footer lines. The header contains an
# arbitrary title specified with the first positional parameter. The
# output is preceded and followed by an additional newline to make it
# stand out more.
#
# Globals:
#   none
# Arguments:
#   $1 - title
# Returns:
#   none
# Inputs:
#   STDIN - text to enclose
# Outputs:
#   STDOUT - enclosed text
batslib_decorate() {
  echo
  echo "-- $1 --"
  cat -
  echo '--'
  echo
}
