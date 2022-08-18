################################################################################
#
# xone
#
################################################################################
# Version. Commits on Jun 20, 2022
XONE_VERSION = v0.3
XONE_SITE = $(call github,medusalix,xone,$(XONE_VERSION))
XONE_DEPENDENCIES = 
XONE_LICENSE = GPL-2.0

XONE_MODULE_MAKE_OPTS = \
        TopDIR=$(@D) \
        # KVER=$(LINUX_VERSION_PROBED)
        USER_EXTRA_CFLAGS="-DCONFIG_$(call qstrip,$(BR2_ENDIAN))_ENDIAN \
                -Wno-error"

$(eval $(kernel-module))
$(eval $(generic-package))
