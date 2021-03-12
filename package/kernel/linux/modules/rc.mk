RC_MENU:=Remote Controller support

define KernelPackage/rc
  SUBMENU:=$(RC_MENU)
  TITLE:=Support for Remote Control devices (with lirc)
  DEPENDS:=+kmod-input-core
  KCONFIG:= \
	CONFIG_RC_CORE=y \
	CONFIG_RC_MAP=y \
	CONFIG_LIRC=y \
	CONFIG_BPF_LIRC_MODE2=n
  FILES:=$(LINUX_DIR)/drivers/media/rc/rc-core.ko
endef

define KernelPackage/rc/description
 Kernel support for Remote Control devices
endef

$(eval $(call KernelPackage,rc))

define KernelPackage/rc-gpio
  SUBMENU:=$(RC_MENU)
  TITLE:=Support for gpio IR device drivers
  DEPENDS:=kmod-rc
  KCONFIG:=CONFIG_RC_DEVICES=y \
	CONFIG_IR_GPIO_CIR=y \
	CONFIG_PWM=y \
	CONFIG_IR_GPIO_TX=y \
	CONFIG_IR_PWM_TX=y \
	CONFIG_IR_IMON_RAW=n \
	CONFIG_IR_SPI=n \
	CONFIG_IR_SERIAL=n \
	CONFIG_IR_SIR=n \
	CONFIG_RC_XBOX_DVD=n
  FILES:=$(LINUX_DIR)/drivers/media/rc/gpio-ir-recv.ko \
	$(LINUX_DIR)/drivers/media/rc/gpio-ir-tx.ko \
	$(LINUX_DIR)/drivers/media/rc/pwm-ir-tx.ko
  AUTOLOAD:=$(call AutoProbe,gpio-ir-recv gpio-ir-tx pwm-ir-tx)
endef

define KernelPackage/rc-gpio/description
 Kernel support for GPIO IR Remote Drivers
endef

$(eval $(call KernelPackage,rc-gpio))

define KernelPackage/rc-decoders
  SUBMENU:=$(RC_MENU)
  TITLE:=Support for Remote Control protocols
  DEPENDS:=kmod-rc
  KCONFIG:=CONFIG_RC_DECODERS=y \
	CONFIG_IR_NEC_DECODER=y \
	CONFIG_IR_RC5_DECODER=y \
	CONFIG_IR_RC6_DECODER=y \
	CONFIG_IR_JVC_DECODER=y \
	CONFIG_IR_SONY_DECODER=y \
	CONFIG_IR_SANYO_DECODER=y \
	CONFIG_IR_SHARP_DECODER=y \
	CONFIG_IR_MCE_KBD_DECODER=y \
	CONFIG_IR_XMP_DECODER=y \
	CONFIG_IR_IMON_DECODER=y \
	CONFIG_IR_RCMM_DECODER=y
  FILES:=$(LINUX_DIR)/drivers/media/rc/ir-nec-decoder.ko \
	$(LINUX_DIR)/drivers/media/rc/ir-rc5-decoder.ko \
	$(LINUX_DIR)/drivers/media/rc/ir-rc6-decoder.ko \
	$(LINUX_DIR)/drivers/media/rc/ir-jvc-decoder.ko \
	$(LINUX_DIR)/drivers/media/rc/ir-sony-decoder.ko \
	$(LINUX_DIR)/drivers/media/rc/ir-sanyo-decoder.ko \
	$(LINUX_DIR)/drivers/media/rc/ir-sharp-decoder.ko \
	$(LINUX_DIR)/drivers/media/rc/ir-mce_kbd-decoder.ko \
	$(LINUX_DIR)/drivers/media/rc/ir-xmp-decoder.ko \
	$(LINUX_DIR)/drivers/media/rc/ir-imon-decoder.ko \
	$(LINUX_DIR)/drivers/media/rc/ir-rcmm-decoder.ko
  AUTOLOAD:=$(call AutoProbe,\
	ir-nec-decoder ir-rc5-decoder ir-rc6-decoder ir-jvc-decoder ir-sony-decoder ir-sanyo-decoder\
	ir-sharp-decoder ir-mce_kbd-decoder ir-xmp-decoder ir-imon-decoder ir-rcmm-decoder)
endef

define KernelPackage/rc-decoders/description
 Kernel support for Remote Control protocols
endef

$(eval $(call KernelPackage,rc-decoders))
