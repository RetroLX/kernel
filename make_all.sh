#!/bin/bash

# Source secret GitHub token
source ./gh_token

# Mainline kernels based on official version
KERNEL_VERSION="5.15.38"

# Allwinner kernels
make kernel-aw32-build
#TARGET=aw32 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
make kernel-sun50i-build
#TARGET=sun50i VERSION=${KERNEL_VERSION} ./upload_kernel.sh

# Amlogic kernels
make kernel-s812-build
#TARGET=s812 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
make kernel-meson64-build
#TARGET=meson64 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
make kernel-s905gen3-build
#TARGET=s905gen3 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
make kernel-s922x-build
#TARGET=s922x VERSION=${KERNEL_VERSION} ./upload_kernel.sh

# Rockchip kernels
make kernel-rk3288-build
#TARGET=rk3288 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
make kernel-rk3326-build
#TARGET=rk3326 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
make kernel-rk3328-build
#TARGET=rk3328 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
make kernel-rk3399-build
#TARGET=rk3399 VERSION=${KERNEL_VERSION} ./upload_kernel.sh

# Samsung kernels
make kernel-exynos5422-build
#TARGET=exynos5422 VERSION=${KERNEL_VERSION} ./upload_kernel.sh

# Generic x86/x86_64 kernels
#make kernel-x86-build
#TARGET=x86 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
make kernel-x86_64-build
#TARGET=x86_64 VERSION=${KERNEL_VERSION} ./upload_kernel.sh

# Raspberry Pi kernels
KERNEL_VERSION="5.15.36"
make kernel-rpi1-build
#TARGET=rpi1 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
make kernel-rpi2-build
#TARGET=rpi2 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
make kernel-rpi3-build
#TARGET=rpi3 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
make kernel-rpi4-build
#TARGET=rpi4 VERSION=${KERNEL_VERSION} ./upload_kernel.sh

# WIP kernels
KERNEL_VERSION="5.17.6"
make kernel-rk356x-build
