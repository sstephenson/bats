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
echo "Installing binaries..."

[[ -d "$PREFIX"/share/bats ]] || mkdir -p "$PREFIX"/share/bats
[[ -d "$PREFIX"/bin ]] || mkdir -p "$PREFIX"/bin

cp -Rv "$BATS_ROOT"/libexec/* "$PREFIX"/share/bats

for binary in $(ls -1 libexec); do 
  ln -svf "$PREFIX"/share/bats/${binary} "$PREFIX"/bin/${binary}
done

echo "Installed bats into ${PREFIX}/bin:"

ls -al ${PREFIX}/bin/bats*
