################################################################################
#
# retrolx nvidia-kernel-module
#
################################################################################

RETROLX_NVIDIA_KERNEL_MODULE_VERSION = 510.68.02
RETROLX_NVIDIA_KERNEL_MODULE_SUFFIX = $(if $(BR2_x86_64),_64)
RETROLX_NVIDIA_KERNEL_MODULE_SITE = http://download.nvidia.com/XFree86/Linux-x86$(RETROLX_NVIDIA_KERNEL_MODULE_SUFFIX)/$(RETROLX_NVIDIA_KERNEL_MODULE_VERSION)
RETROLX_NVIDIA_KERNEL_MODULE_SOURCE = NVIDIA-Linux-x86$(RETROLX_NVIDIA_KERNEL_MODULE_SUFFIX)-$(RETROLX_NVIDIA_KERNEL_MODULE_VERSION).run
RETROLX_NVIDIA_KERNEL_MODULE_LICENSE = NVIDIA Software License
RETROLX_NVIDIA_KERNEL_MODULE_LICENSE_FILES = LICENSE
RETROLX_NVIDIA_KERNEL_MODULE_REDISTRIBUTE = NO
RETROLX_NVIDIA_KERNEL_MODULE_INSTALL_STAGING = YES

RETROLX_NVIDIA_KERNEL_MODULE_MODULES = nvidia nvidia-modeset nvidia-drm
ifeq ($(BR2_x86_64),y)
RETROLX_NVIDIA_KERNEL_MODULE_MODULES += nvidia-uvm
endif

# They can't do everything like everyone. They need those variables,
# because they don't recognise the usual variables set by the kernel
# build system. We also need to tell them what modules to build.
RETROLX_NVIDIA_KERNEL_MODULE_MODULE_MAKE_OPTS = \
	NV_KERNEL_SOURCES="$(LINUX_DIR)" \
	NV_KERNEL_OUTPUT="$(LINUX_DIR)" \
	NV_KERNEL_MODULES="$(RETROLX_NVIDIA_KERNEL_MODULE_MODULES)" \
	IGNORE_CC_MISMATCH="1"


RETROLX_NVIDIA_KERNEL_MODULE_MODULE_SUBDIRS = kernel

$(eval $(kernel-module))

# The downloaded archive is in fact an auto-extract script. So, it can run
# virtually everywhere, and it is fine enough to provide useful options.
# Except it can't extract into an existing (even empty) directory.
define RETROLX_NVIDIA_KERNEL_MODULE_EXTRACT_CMDS
	$(SHELL) $(RETROLX_NVIDIA_KERNEL_MODULE_DL_DIR)/$(RETROLX_NVIDIA_KERNEL_MODULE_SOURCE) --extract-only --target \
		$(@D)/tmp-extract
	chmod u+w -R $(@D)
	mv $(@D)/tmp-extract/* $(@D)/tmp-extract/.manifest $(@D)
	rm -rf $(@D)/tmp-extract
endef

# For target, install kernel module
define RETROLX_NVIDIA_KERNEL_MODULE_INSTALL_TARGET_CMDS
	$(RETROLX_NVIDIA_KERNEL_MODULE_INSTALL_KERNEL_MODULE)
endef

$(eval $(generic-package))
