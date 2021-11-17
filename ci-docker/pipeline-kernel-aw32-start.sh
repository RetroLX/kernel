#!/bin/bash
# Builds a RetroLX kernel

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "$SCRIPT_DIR"

docker pull retrolx/build-environment-ubuntu-20.10
docker run -v "$SCRIPT_DIR":/ci-docker --add-host invisible-mirror.net:1.1.1.1 --add-host mirror.keystealth.org:1.1.1.1 --entrypoint /ci-docker/pipeline-kernel-aw32.sh retrolx/build-environment-ubuntu-20.10 > allout.log 2>&1 &
