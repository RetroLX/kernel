################################################################################
#
# RTL8723DS
#
################################################################################

RTL8723DS_VERSION = 76fb80685be9920a1d5ac7003102dcdfb76daa6b
RTL8723DS_SITE = $(call github,lwfinger,rtl8723ds,$(RTL8723DS_VERSION))
RTL8723DS_LICENSE = GPL-2.0
RTL8723DS_LICENSE_FILES = LICENSE

RTL8723DS_MODULE_MAKE_OPTS = \
	CONFIG_RTL8723DS=m \
# batocera: setting KVER breaks top level parallelization
	# KVER=$(LINUX_VERSION_PROBED)
	USER_EXTRA_CFLAGS="-DCONFIG_$(call qstrip,$(BR2_ENDIAN))_ENDIAN \
		-Wno-error"

define RTL8723DS_MAKE_SUBDIR
        (cd $(@D); ln -s . RTL8723DS)
endef

RTL8723DS_PRE_CONFIGURE_HOOKS += RTL8723DS_MAKE_SUBDIR

$(eval $(kernel-module))
$(eval $(generic-package))
