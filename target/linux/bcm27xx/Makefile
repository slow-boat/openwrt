# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2012-2020 OpenWrt.org
# Copyright (C) 2017 LEDE project

include $(TOPDIR)/rules.mk

ARCH:=arm
BOARD:=bcm27xx
BOARDNAME:=Broadcom BCM27xx
FEATURES:=ext4 audio usb usbgadget display gpio fpu squashfs rootfs-part boot-part
SUBTARGETS:=bcm2708 bcm2709 bcm2710 bcm2711

KERNEL_PATCHVER=5.4

define Target/Description
	Build firmware image for Broadcom BCM27xx SoC devices.
	Currently produces SD Card image for Raspberry Pi.
endef

include $(INCLUDE_DIR)/target.mk

DEFAULT_PACKAGES := $(filter-out urngd,$(DEFAULT_PACKAGES))
DEFAULT_PACKAGES += \
	bcm27xx-gpu-fw \
	kmod-usb-hid \
	kmod-fs-vfat kmod-nls-cp437 kmod-nls-iso8859-1 \
	partx-utils mkf2fs e2fsprogs \
	libiwinfo-lua \
	kmod-gpio-dev kmod-gpio-pcf857x kmod-rc-gpio kmod-input-gpio-encoder kmod-input-gpio-keys \
	kmod-random-core kmod-regmap-core \
	kmod-hwmon-core kmod-hwmon-raspberrypi \
	kmod-i2c-core kmod-i2c-bcm2835 kmod-i2c-gpio kmod-i2c-mux kmod-i2c-mux-gpio libi2c i2c-tools \
	kmod-i2c-algo-bit kmod-i2c-smbus kmod-regmap-i2c kmod-smi-bcm2835 kmod-smi-bcm2835-dev \
	kmod-spi-bcm2835 kmod-spi-bcm2835-aux kmod-spi-bitbang kmod-spi-dev kmod-regmap-spi \
	kmod-backlight kmod-backlight-pwm kmod-fb kmod-fb-cfb-copyarea kmod-fb-cfb-fillrect kmod-fb-cfb-imgblt \
	kmod-fb-sys-fops kmod-fb-sys-ram kmod-fb-tft kmod-fb-tft-ili9341 libsensors lm-sensors \
	kmod-sound-core kmod-sound-soc-bcm2835-i2s kmod-sound-soc-audioinjector-pi-soundcard

KERNELNAME:=Image dtbs

$(eval $(call BuildTarget))
