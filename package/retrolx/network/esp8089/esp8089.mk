################################################################################
#
# ESP8089
#
################################################################################

ESP8089_VERSION = fef37cfed761803c4462453dba2d2efebbb659b2
ESP8089_SITE = $(call github,al177,esp8089,$(ESP8089_VERSION))
ESP8089_LICENSE = GPL-2.0
ESP8089_LICENSE_FILES = LICENSE

ESP8089_MODULE_MAKE_OPTS = \
	CONFIG_ESP8089=m \
# batocera: setting KVER breaks top level parallelization
	# KVER=$(LINUX_VERSION_PROBED)
	USER_EXTRA_CFLAGS="-DCONFIG_$(call qstrip,$(BR2_ENDIAN))_ENDIAN \
		-Wno-error"

$(eval $(kernel-module))
$(eval $(generic-package))
