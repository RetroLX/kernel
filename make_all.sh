#!/bin/bash

# Source secret GitHub token
source ./gh_token

#KERNEL_VERSION=$(date '+%Y-%m-%d')

# Custom kernels based on current date
#make kernel-s812-build
#make kernel-h616-build
#TARGET=s812 VERSION=${KERNEL_VERSION} ./upload_kernel.sh

# Mainline kernels based on official version
KERNEL_VERSION="5.10.50"

# Amlogic kernels
#make kernel-s905-build
make kernel-s912-build
make kernel-s922x-build
make kernel-sm1-build
#TARGET=s905 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
TARGET=s912 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
TARGET=s922x VERSION=${KERNEL_VERSION} ./upload_kernel.sh
TARGET=sm1 VERSION=${KERNEL_VERSION} ./upload_kernel.sh

# Rockchip kernels
make kernel-rk3288-build
#make kernel-rk3326-build
make kernel-rk3399-build
TARGET=rk3288 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
#TARGET=rk3326 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
TARGET=rk3399 VERSION=${KERNEL_VERSION} ./upload_kernel.sh

# Raspberry Pi kernels
#make kernel-rpi1-build
#make kernel-rpi2-build
#make kernel-rpi3-build
#make kernel-rpi4-build
#TARGET=rpi1 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
#TARGET=rpi2 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
#TARGET=rpi3 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
#TARGET=rpi4 VERSION=${KERNEL_VERSION} ./upload_kernel.sh

# Samsung kernels
make kernel-exynos5422-build
TARGET=exynos5422 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
