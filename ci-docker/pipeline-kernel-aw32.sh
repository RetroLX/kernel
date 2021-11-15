#!/bin/bash
# Builds a RetroLX kernel

date
cd /ci-docker
git clone https://github.com/RetroLX/kernel.git
cd kernel
git submodule init
git submodule update
make kernel-aw32-build
date
