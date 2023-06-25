include $(TOPDIR)/rules.mk

PKG_NAME:=rtl8723ds
PKG_RELEASE:=1.0

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=

PKG_SOURCE_URL:=https://github.com/lwfinger/rtl8723ds.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2023-05-03
PKG_SOURCE_VERSION:=c65bc55a369275c5eae0c9b1c4caf3d0aea64b02
PKG_MIRROR_HASH:=f4e115c41000a40406fc70a79f1db133858c858b37442d8cb6501593efa84e91

# PKG_MAINTAINER:=
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define KernelPackage/rtl8723ds
  SUBMENU:=Wireless Drivers
  TITLE:=Realtek rtl8723ds
  DEPENDS:=+kmod-cfg80211 +kmod-mmc +@DRIVER_11N_SUPPORT
  FILES:= $(PKG_BUILD_DIR)/rtl8723ds.ko
  AUTOLOAD:=$(call AutoProbe,rtl8723ds)
  PROVIDES:=kmod-rtl8723ds
endef

NOSTDINC_FLAGS = \
	-I$(PKG_BUILD_DIR)/include \
	-I$(STAGING_DIR)/usr/include/mac80211-backport/uapi \
	-I$(STAGING_DIR)/usr/include/mac80211-backport \
	-I$(STAGING_DIR)/usr/include/mac80211-backport/net \
	-I$(STAGING_DIR)/usr/include/mac80211/uapi \
	-I$(STAGING_DIR)/usr/include/mac80211 \
	-I$(STAGING_DIR)/usr/include \
	-include backport/autoconf.h \
	-include backport/backport.h

NOSTDINC_FLAGS += -DCONFIG_IOCTL_CFG80211 -DRTW_USE_CFG80211_STA_EVENT \
	-D_LINUX_BYTEORDER_SWAB_H -DBUILD_OPENWRT -DRTW_SINGLE_WIPHY -DCONFIG_COMPAT

PKG_MAKE_FLAGS += USER_MODULE_NAME=rtl8723ds
PKG_MAKE_FLAGS += USER_DRV_NAME=rtl8723ds
KERNEL_MAKE_FLAGS += CONFIG_RTL8723DS=m CONFIG_SDIO_HCI=y

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C "$(LINUX_DIR)" \
		$(KERNEL_MAKE_FLAGS) \
		$(PKG_MAKE_FLAGS) \
		M="$(PKG_BUILD_DIR)" \
		$(if $(CONFIG_BIG_ENDIAN),NOSTDINC_FLAGS="$(NOSTDINC_FLAGS) -DCONFIG_BIG_ENDIAN", \
		NOSTDINC_FLAGS="$(NOSTDINC_FLAGS) -DCONFIG_LITTLE_ENDIAN") \
		modules
endef

$(eval $(call KernelPackage,rtl8723ds))
