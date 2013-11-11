#!/usr/bin/env bash
set -e

resolve_link() {
  $(type -p greadlink readlink | head -1) "$1"
}

abs_dirname() {
  local cwd="$(pwd)"
  local path="$1"

  while [ -n "$path" ]; do
    cd "${path%/*}"
    local name="${path##*/}"
    path="$(resolve_link "$name" || true)"
  done

  pwd
  cd "$cwd"
}

PREFIX="$1"
if [ -z "$1" ]; then
  { echo "usage: $0 <prefix>"
    echo "  e.g. $0 /usr/local"
  } >&2
  exit 1
fi

BATS_ROOT="$(abs_dirname "$0")"
mkdir -p "$PREFIX"/{bin,libexec,share/man/man{1,7}}
cp -R "$BATS_ROOT"/bin/* "$PREFIX"/bin
cp -R "$BATS_ROOT"/libexec/* "$PREFIX"/libexec
cp "$BATS_ROOT"/man/bats.1 "$PREFIX"/share/man/man1
cp "$BATS_ROOT"/man/bats.7 "$PREFIX"/share/man/man7

echo "Installed Bats to $PREFIX/bin/bats"
