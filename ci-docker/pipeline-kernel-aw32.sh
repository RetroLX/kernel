#!/bin/bash
# Builds a RetroLX kernel

date
printenv
cd /ci-docker
git clone https://github.com/RetroLX/kernel.git
cd kernel
git checkout ci-wip
git submodule init
git submodule update
make kernel-aw32-build
date
