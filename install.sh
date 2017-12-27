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

print_usage() {
  { echo "usage: $0 <prefix>"
    echo "  e.g. $0 /usr/local"
    echo "uninstall: $0 -u [-i] [<prefix>]"
    echo "  e.g. $0 -u -i /usr/local"
    echo "  e.g. $0 -u"
  } >&2
  exit 1  
}

add_to_uninstall() {
  pushd . >/dev/null
  cd $1
  for i in $(ls $3); do
    FILE=$2/$i
    if [ -e $FILE ]; then 
      DELETE_FILES+=( $FILE )
    else
      UNKNOWN_FILES+=( $FILE )
    fi
  done
  popd >/dev/null
}

# parse command line
UNINSTALL=false
INTERACTIVE=true
for i in $@; do
  if [ $i == "-u" ]; then
    UNINSTALL=true
  elif [ $i == "-i" ]; then
    # the -i suppresses comfirmations
    INTERACTIVE=false
  else
    # don't permit two prefixes
    if [ ! -z "$PREFIX" ]; then print_usage; fi
    PREFIX=$i
  fi
done

# validate command line
if [ -z "$PREFIX" ]; then 
  if $UNINSTALL ; then
    # no prefix necessary if uninstalling
    set +e
    PREFIX=$(which bats) 
    if [ 0 -eq $? ]; then
      PREFIX=$(echo $PREFIX | sed -e 's$/[^/]*/bats\$$$')
    else 
      echo "bats not in system path. Specify prefix." >&2
      exit 2
    fi
    set -e    
  else
    print_usage; 
  fi
fi

# complete the install/uninstall process
BATS_ROOT="$(abs_dirname "$0")"
if $UNINSTALL; then
  DELETE_FILES=()
  UNKNOWN_FILES=()
  CONTINUE=false
  pushd . >/dev/null
  cd $BATS_ROOT
  # get a list of files to delete
  add_to_uninstall bin "$PREFIX"/bin '*'
  add_to_uninstall libexec "$PREFIX"/libexec '*'
  add_to_uninstall man "$PREFIX"/share/man/man1 '*.1'
  add_to_uninstall man "$PREFIX"/share/man/man7 '*.7'
  # confirm deletion
  if $INTERACTIVE; then
    if [ ${#DELETE_FILES[@]} -ne 0 ]; then
      echo DELETING FILES
      for i in ${DELETE_FILES[@]}; do
        echo -e '\t'$i
      done
    fi
    if [ ${#UNKNOWN_FILES[@]} -ne 0 ]; then
      echo UNKNOWN FILES
      for i in ${UNKNOWN_FILES[@]}; do
        echo -e '\t'$i
      done
    fi
  else
    CONTINUE=true
  fi
  if $INTERACTIVE; then
    if [ ${#DELETE_FILES[@]} -ne 0 ]; then
      read -p "Press [y] to continue, [n] to cancel" -n 1 -r -s
      if [ "$REPLY" == 'y' ]; then
        echo ' -- Continuing'
        CONTINUE=true
      else 
        echo ' -- CANCELING'
      fi
    else
      CONTINUE=false
    fi
  fi
  # delete the files
  if $CONTINUE; then 
    rm ${DELETE_FILES[@]}
  fi
  popd >/dev/null
  true
else
  mkdir -p "$PREFIX"/{bin,libexec,share/man/man{1,7}}
  cp -R "$BATS_ROOT"/bin/* "$PREFIX"/bin
  cp -R "$BATS_ROOT"/libexec/* "$PREFIX"/libexec
  cp "$BATS_ROOT"/man/bats.1 "$PREFIX"/share/man/man1
  cp "$BATS_ROOT"/man/bats.7 "$PREFIX"/share/man/man7

  echo "Installed Bats to $PREFIX/bin/bats"
fi