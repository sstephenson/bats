#!/usr/bin/env bash

set -e

run_with_bash() {
  # shellcheck disable=SC2016
  printf 'Running tests with bash %s\n\n' "$("$1/bash" -c 'echo $BASH_VERSION')"

  (
    PATH="$1":$PATH bin/bats --tap test
    PATH="$1":$PATH bin/bats --pretty test
  )

  printf '\n'
}

for v in 3.1 3.2 4.0 4.1 4.2 4.3 4.4 ; do
  printf 'Building bash %s\n\n' $v

  wget --quiet https://ftp.gnu.org/gnu/bash/bash-$v.tar.gz
  tar -xf bash-$v.tar.gz
  rm bash-$v.tar.gz

  (
    cd bash-$v
    ./configure > /dev/null 2>&1
    make > /dev/null 2>&1
  )

  run_with_bash bash-$v

  printf 'Rebuilding bash %s with latest patch level\n\n' $v
  (
    cd bash-$v
    wget -q --cut-dirs=100 -r --no-parent https://ftp.gnu.org/gnu/bash/bash-$v-patches/
    mv ftp.gnu.org bash-$v-patches/
    ( cd bash-$v-patches && cat bash??-??? ) | patch -s -p0 || exit 1
    make > /dev/null 2>&1
  )

  run_with_bash bash-$v

  rm -rf bash-$v
done
