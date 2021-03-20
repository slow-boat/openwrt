#
# Copyright (C) 2010-2015 OpenWrt.org
#

. /lib/imx6.sh
. /lib/functions.sh

RAMFS_COPY_BIN='blkid jffs2reset'

enable_image_metadata_check() {
	case "$(board_name)" in
		toradex,apalis_imx6q-eval |\
		toradex,apalis_imx6q-ixora |\
		toradex,apalis_imx6q-ixora-v1.1 |\
		wand,wandboard |\
		solidrun,cubox-i/dl |\
		solidrun,cubox-i/q )
			REQUIRE_IMAGE_METADATA=1
			;;
	esac
}
enable_image_metadata_check

apalis_copy_config() {
	apalis_mount_boot
	cp -af "$UPGRADE_BACKUP" "/boot/$BACKUP_FILE"
	sync
	umount /boot
}

apalis_do_upgrade() {
	apalis_mount_boot
	get_image "$1" | tar Oxf - sysupgrade-apalis/kernel > /boot/uImage
	get_image "$1" | tar Oxf - sysupgrade-apalis/root > $(rootpart_from_uuid)
	sync
	umount /boot
}

sdcard_check_image() {
	local diskdev partdev diff

	[ "$#" -gt 1 ] && return 1

	export_bootdevice && export_partdevice diskdev 0 || {
		echo "Unable to determine upgrade device"
		return 1
	}

	get_partitions "/dev/$diskdev" bootdisk

	#extract the boot sector from the image
	get_image "$@" | dd of=/tmp/image.bs count=1 bs=512b 2>/dev/null

	get_partitions /tmp/image.bs image

	#compare tables
	diff="$(grep -F -x -v -f /tmp/partmap.bootdisk /tmp/partmap.image)"

	rm -f /tmp/image.bs /tmp/partmap.bootdisk /tmp/partmap.image

	if [ -n "$diff" ]; then
		echo "Partition layout has changed. Full image will be written."
		ask_bool 0 "Abort" && exit 1
		return 0
	fi

	return 0;	
}

sdcard_do_upgrade() {
	local diskdev partdev diff

	export_bootdevice && export_partdevice diskdev 0 || {
		echo "Unable to determine upgrade device"
		return 1
	}

	sync

	if [ "$UPGRADE_OPT_SAVE_PARTITIONS" = "1" ]; then
		get_partitions "/dev/$diskdev" bootdisk

		#extract the boot sector from the image
		get_image "$@" | dd of=/tmp/image.bs count=1 bs=512b

		get_partitions /tmp/image.bs image

		#compare tables
		diff="$(grep -F -x -v -f /tmp/partmap.bootdisk /tmp/partmap.image)"
	else
		diff=1
	fi

	if [ -n "$diff" ]; then
		get_image "$@" | dd of="/dev/$diskdev" bs=2M conv=fsync

		# Separate removal and addtion is necessary; otherwise, partition 1
		# will be missing if it overlaps with the old partition 2
		partx -d - "/dev/$diskdev"
		partx -a - "/dev/$diskdev"

		return 0
	fi

	#iterate over each partition from the image and write it to the boot disk
	while read part start size; do
		if export_partdevice partdev $part; then
			echo "Writing image to /dev/$partdev..."
			get_image "$@" | dd of="/dev/$partdev" ibs="512" obs=1M skip="$start" count="$size" conv=fsync
		else
			echo "Unable to find partition $part device, skipped."
	fi
	done < /tmp/partmap.image

	#copy partition uuid
	echo "Writing new UUID to /dev/$diskdev..."
	get_image "$@" | dd of="/dev/$diskdev" bs=1 skip=440 count=4 seek=440 conv=fsync	
}

sdcard_copy_config() {
	local partdev

	if export_partdevice partdev 1; then
		mkdir -p /boot
		[ -f /boot/uImage ] || mount -o rw,noatime "/dev/$partdev" /boot
		cp -af "$UPGRADE_BACKUP" "/boot/$BACKUP_FILE"
		sync
		umount /boot
	fi	
}

platform_check_image() {
	local board=$(board_name)

	case "$board" in
	gw,imx6dl-gw51xx |\
	gw,imx6dl-gw52xx |\
	gw,imx6dl-gw53xx |\
	gw,imx6dl-gw54xx |\
	gw,imx6dl-gw551x |\
	gw,imx6dl-gw552x |\
	gw,imx6dl-gw553x |\
	gw,imx6dl-gw5904 |\
	gw,imx6dl-gw5907 |\
	gw,imx6dl-gw5910 |\
	gw,imx6dl-gw5912 |\
	gw,imx6dl-gw5913 |\
	gw,imx6q-gw51xx |\
	gw,imx6q-gw52xx |\
	gw,imx6q-gw53xx |\
	gw,imx6q-gw5400-a |\
	gw,imx6q-gw54xx |\
	gw,imx6q-gw551x |\
	gw,imx6q-gw552x |\
	gw,imx6q-gw553x |\
	gw,imx6q-gw5904 |\
	gw,imx6q-gw5907 |\
	gw,imx6q-gw5910 |\
	gw,imx6q-gw5912 |\
	gw,imx6q-gw5913 )
		nand_do_platform_check $board $1
		return $?;
		;;
	toradex,apalis_imx6q-eval |\
	toradex,apalis_imx6q-ixora |\
	toradex,apalis_imx6q-ixora-v1.1 )
		return 0
		;;
	wand,wandboard |\
	solidrun,cubox-i/dl |\
	solidrun,cubox-i/q )
		sdcard_check_image "$1"
		return $?
		;;
	esac

	echo "Sysupgrade is not yet supported on $board."
	return 1
}

platform_do_upgrade() {
	local board=$(board_name)

	case "$board" in
	gw,imx6dl-gw51xx |\
	gw,imx6dl-gw52xx |\
	gw,imx6dl-gw53xx |\
	gw,imx6dl-gw54xx |\
	gw,imx6dl-gw551x |\
	gw,imx6dl-gw552x |\
	gw,imx6dl-gw553x |\
	gw,imx6dl-gw5904 |\
	gw,imx6dl-gw5907 |\
	gw,imx6dl-gw5910 |\
	gw,imx6dl-gw5912 |\
	gw,imx6dl-gw5913 |\
	gw,imx6q-gw51xx |\
	gw,imx6q-gw52xx |\
	gw,imx6q-gw53xx |\
	gw,imx6q-gw5400-a |\
	gw,imx6q-gw54xx |\
	gw,imx6q-gw551x |\
	gw,imx6q-gw552x |\
	gw,imx6q-gw553x |\
	gw,imx6q-gw5904 |\
	gw,imx6q-gw5907 |\
	gw,imx6q-gw5910 |\
	gw,imx6q-gw5912 |\
	gw,imx6q-gw5913 )
		nand_do_upgrade "$1"
		;;
	toradex,apalis_imx6q-eval |\
	toradex,apalis_imx6q-ixora |\
	toradex,apalis_imx6q-ixora-v1.1 )
		apalis_do_upgrade "$1"
		;;
	wand,wandboard |\
	solidrun,cubox-i/dl |\
	solidrun,cubox-i/q )
		sdcard_do_upgrade "$1"
		;;
	esac
}

platform_copy_config() {
	local board=$(board_name)

	case "$board" in
	toradex,apalis_imx6q-eval |\
	toradex,apalis_imx6q-ixora |\
	toradex,apalis_imx6q-ixora-v1.1 )
		apalis_copy_config
		;;
	wand,wandboard |\
	solidrun,cubox-i/dl |\
	solidrun,cubox-i/q )
		sdcard_copy_config "$1"
		;;			
	esac
}

platform_pre_upgrade() {
	local board=$(board_name)

	case "$board" in
	toradex,apalis_imx6q-eval |\
	toradex,apalis_imx6q-ixora |\
	toradex,apalis_imx6q-ixora-v1.1 |\
	wand,wandboard |\
	solidrun,cubox-i/dl |\
	solidrun,cubox-i/q)
		[ -z "$UPGRADE_BACKUP" ] && {
			jffs2reset -y
			umount /overlay
		}
		;;
	esac
}
