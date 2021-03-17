![OpenWrt logo](include/logo.png)

## Audio Overlay
To add audio overlay, we need to make a config file for the target you wish to use.
There are several critical config overrides for the audio application to work, these
are appended to the base config, and like magic it should just work on your selected platform.
Then run `cat configs/audio-overlay.config >> .config`, followed by `make defconfig` to clean up.
It might be necessary to run `rm -f tmp` and `make clean` if build was done previously
due to the deselection of IPV6 support.

File overlays are added in a configs subdirectory defined by `configs/<arch>-<profile>`.
For example `configs/x86_64-generic.files` for x86, `configs/arm-rpi.files` for a Rpi.
The specified directory is recursively copied to `upgrade` directory in the boot partition
during the image creation stage.

On boot, the system mounts the boot partition as `/boot`.

`/boot/upgrades/*` is recursively copied over the root directory,
before expansion and overlay of any `/sysupgrade.tgz` archive that might have been added.
File permissions are forced to `0x600` for all files, since the file system is usually FAT,
so original linux permissions are lost.

The purpose of this additional overlay is to have a target-specific base config setup that can
be manually edited offline, by removing the storage and accessing it on another host.

By mounting the image boot partition on another host, the user can modify the default settings
included in the build files overlay specified in `configs/<arch>-<profile>`.

It allows things such as wifi authentication and hostname to be configured so that the device can be
brought online without an ethernet port or other provisioning, and accessed via dhcp servers
dns entry based on hostname.

For convenience, on SD card based images, the "upgrade" folder can be added and new files
installed as a means to inject packages or upgrade system files. This is important since the 
root partition is usually read only squashfs.

For more complex upgrades, the package should be archived as a tar.gz file, and copied to boot
partition `upgrades/sysupgrade.tgz` such that the normal sysupgrade process can be invoked.

## Default

OpenWrt Project is a Linux operating system targeting embedded devices. Instead
of trying to create a single, static firmware, OpenWrt provides a fully
writable filesystem with package management. This frees you from the
application selection and configuration provided by the vendor and allows you
to customize the device through the use of packages to suit any application.
For developers, OpenWrt is the framework to build an application without having
to build a complete firmware around it; for users this means the ability for
full customization, to use the device in ways never envisioned.

Sunshine!

## Development

To build your own firmware you need a GNU/Linux, BSD or MacOSX system (case
sensitive filesystem required). Cygwin is unsupported because of the lack of a
case sensitive file system.

### Requirements

You need the following tools to compile OpenWrt, the package names vary between
distributions. A complete list with distribution specific packages is found in
the [Build System Setup](https://openwrt.org/docs/guide-developer/build-system/install-buildsystem)
documentation.

```
gcc-6+ binutils bzip2 flex python3 perl make4.1+ find grep diff unzip gawk getopt
subversion libz-dev libc-dev rsync which
```

### Quickstart

1. Run `./scripts/feeds update -a` to obtain all the latest package definitions
   defined in feeds.conf / feeds.conf.default

2. Run `./scripts/feeds install -a` to install symlinks for all obtained
   packages into package/feeds/

3. Run `make menuconfig` to select your preferred configuration for the
   toolchain, target system & firmware packages.

4. Run `make` to build your firmware. This will download all sources, build the
   cross-compile toolchain and then cross-compile the GNU/Linux kernel & all chosen
   applications for your target system.

### Related Repositories

The main repository uses multiple sub-repositories to manage packages of
different categories. All packages are installed via the OpenWrt package
manager called `opkg`. If you're looking to develop the web interface or port
packages to OpenWrt, please find the fitting repository below.

* [LuCI Web Interface](https://github.com/openwrt/luci): Modern and modular
  interface to control the device via a web browser.

* [OpenWrt Packages](https://github.com/openwrt/packages): Community repository
  of ported packages.

* [OpenWrt Routing](https://github.com/openwrt-routing/packages): Packages
  specifically focused on (mesh) routing.

## Support Information

For a list of supported devices see the [OpenWrt Hardware Database](https://openwrt.org/supported_devices)

### Documentation

* [Quick Start Guide](https://openwrt.org/docs/guide-quick-start/start)
* [User Guide](https://openwrt.org/docs/guide-user/start)
* [Developer Documentation](https://openwrt.org/docs/guide-developer/start)
* [Technical Reference](https://openwrt.org/docs/techref/start)

### Support Community

* [Forum](https://forum.openwrt.org): For usage, projects, discussions and hardware advise.
* [Support Chat](https://webchat.freenode.net/#openwrt): Channel `#openwrt` on freenode.net.

### Developer Community

* [Bug Reports](https://bugs.openwrt.org): Report bugs in OpenWrt
* [Dev Mailing List](https://lists.openwrt.org/mailman/listinfo/openwrt-devel): Send patches
* [Dev Chat](https://webchat.freenode.net/#openwrt-devel): Channel `#openwrt-devel` on freenode.net.

## License

OpenWrt is licensed under GPL-2.0
