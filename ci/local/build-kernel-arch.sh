#!/bin/bash
# Builds a RetroLX kernel

date
printenv
cd /ci-docker # This line will work on docker and fail localy
git clone https://github.com/RetroLX/kernel.git
cd kernel
git submodule init
git submodule update
make kernel-$1-build
date
