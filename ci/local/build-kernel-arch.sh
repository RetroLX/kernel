#!/bin/bash
# Builds a RetroLX kernel

date
printenv

if [ -d "/kernel" ]; then # Docker mounts the repository on this directory
  cd /kernel
else
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    REPOSITORY="$SCRIPT_DIR/../../"
    cd $REPOSITORY
    pwd
fi

git submodule init
git submodule update
make kernel-$1-build
date
