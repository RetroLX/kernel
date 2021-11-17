#!/bin/bash
# Builds a RetroLX kernel

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "$SCRIPT_DIR"
echo "Architecture $1"

docker pull retrolx/build-environment-ubuntu-20.10
docker run -v "$SCRIPT_DIR":/ci-docker --add-host invisible-mirror.net:1.1.1.1 --rm retrolx/build-environment-ubuntu-20.10 --entrypoint /ci-docker/build-kernel-arch.sh $1 > allout.log 2>&1 &
