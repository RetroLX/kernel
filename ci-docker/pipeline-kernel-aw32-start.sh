#!/bin/bash
# Builds a RetroLX kernel

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "$SCRIPT_DIR"

docker pull retrolx/build-environment-ubuntu-20.10
docker run -v "$SCRIPT_DIR":/ci-docker --entrypoint /ci-docker/pipeline-kernel-aw32.sh retrolx/build-environment-ubuntu-20.10
