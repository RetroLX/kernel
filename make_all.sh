#!/bin/bash

# Source secret GitHub token
source ./gh_token

# Custom kernels based on current date
KERNEL_VERSION=$(date '+%Y-%m-%d')
make kernel-s812-build
TARGET=s812 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
make kernel-h616-build
TARGET=h616 VERSION=${KERNEL_VERSION} ./upload_kernel.sh

# Mainline kernels based on official version
KERNEL_VERSION="5.10.60"

# Allwinner kernels
make kernel-h3-build
TARGET=h3 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
make kernel-h5-build
TARGET=h5 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
make kernel-h6-build
TARGET=h6 VERSION=${KERNEL_VERSION} ./upload_kernel.sh

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

# Generic x86/x86_64 kernels
KERNEL_VERSION="5.13.12"
make kernel-x86-build
TARGET=x86 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
make kernel-x86_64-build
TARGET=x86_64 VERSION=${KERNEL_VERSION} ./upload_kernel.sh

# Raspberry kernels based on official version
KERNEL_VERSION="5.10.52"

# Raspberry Pi kernels
make kernel-rpi1-build
TARGET=rpi1 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
make kernel-rpi2-build
TARGET=rpi2 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
make kernel-rpi3-build
TARGET=rpi3 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
make kernel-rpi4-build
TARGET=rpi4 VERSION=${KERNEL_VERSION} ./upload_kernel.sh
