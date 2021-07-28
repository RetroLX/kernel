#!/bin/bash

# Source secret GitHub token
source ./gh_token

# Custom kernels based on current date
KERNEL_VERSION=$(date '+%Y-%m-%d')
#make kernel-s812-build
#make kernel-h616-build
#TARGET=s812 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
#TARGET=h616 VERSION=${KERNEL_VERSION} ./upload_kernel.sh

# Mainline kernels based on official version
KERNEL_VERSION="5.10.54"

# Allwinner kernels
#make kernel-h3-build
#TARGET=h3 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
#make kernel-h5-build
#TARGET=h5 VERSION=${KERNEL_VERSION} ./upload_kernel.sh

# Amlogic kernels
make kernel-s905-build
TARGET=s905  VERSION=${KERNEL_VERSION} ./upload_kernel.sh
make kernel-s912-build
TARGET=s912  VERSION=${KERNEL_VERSION} ./upload_kernel.sh
make kernel-s922x-build
TARGET=s922x VERSION=${KERNEL_VERSION} ./upload_kernel.sh
make kernel-sm1-build
TARGET=sm1   VERSION=${KERNEL_VERSION} ./upload_kernel.sh

# Rockchip kernels
make kernel-rk3288-build
TARGET=rk3288 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
make kernel-rk3326-build
TARGET=rk3326 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
make kernel-rk3399-build
TARGET=rk3399 VERSION=${KERNEL_VERSION} ./upload_kernel.sh

# Samsung kernels
make kernel-exynos5422-build
TARGET=exynos5422 VERSION=${KERNEL_VERSION} ./upload_kernel.sh

# Raspberry kernels based on official version
KERNEL_VERSION="5.10.50"

# Raspberry Pi kernels
#make kernel-rpi1-build
#make kernel-rpi2-build
#make kernel-rpi3-build
#make kernel-rpi4-build
#TARGET=rpi1 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
#TARGET=rpi2 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
#TARGET=rpi3 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
#TARGET=rpi4 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
