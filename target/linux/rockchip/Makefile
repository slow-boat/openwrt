# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

ARCH:=aarch64
BOARD:=rockchip
BOARDNAME:=Rockchip
SUBTARGETS:=generic sound
FEATURES:=ext4 audio usb usbgadget display gpio fpu rootfs-part boot-part squashfs

KERNEL_PATCHVER=5.10
KERNEL_TESTING_PATCHVER=5.10

define Target/Description
	Build firmware image for Rockchip SoC devices.
endef

include $(INCLUDE_DIR)/target.mk

DEFAULT_PACKAGES += uboot-envtools partx-utils e2fsprogs mkf2fs kmod-gpio-button-hotplug

KERNELNAME:=Image dtbs

$(eval $(call BuildTarget))
