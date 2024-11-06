#!/bin/bash

<<COPYLEFT

LibreRouterOS build tools

Copyright (C) 2023  bretello <bretello@distruzione.org>
Copyright (C) 2023-2024  Gioacchino Mazzurco <gio@eigenlab.org>
Copyright (C) 2023-2024  Asociación Civil Altermundi <info@altermundi.net>


This program is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the
Free Software Foundation, version 3.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along
with this program. If not, see <https://www.gnu.org/licenses/>

SPDX-License-Identifier: AGPL-3.0-only

COPYLEFT


## Define default value for variable, take two arguments, $1 variable name,
## $2 default variable value, if the variable is not already define define it
## with default value.
function lo:define_default_value()
{
	VAR_NAME="${1}"
	DEFAULT_VALUE="${2}"

	[ -z "${!VAR_NAME}" ] && export ${VAR_NAME}="${DEFAULT_VALUE}" || true
}

HOME="/mnt/new_disk/compilacionPablo" 
lo:define_default_value BUILD_DEBUG false
lo:define_default_value BUILD_DOWNLOAD_ONLY false
lo:define_default_value BUILD_TARGET "$1"
lo:define_default_value OPENWRT_SRC_DIR "$HOME/Development/openwrt/"
lo:define_default_value OPENWRT_DL_DIR "$HOME/Builds/openwrt-downloads/"
lo:define_default_value LIBREROUTEROS_BUILD_DIR "$HOME/Builds/librerouterOS-$BUILD_TARGET/"
lo:define_default_value LIBREMESH_FEED "src-git libremesh https://github.com/libremesh/lime-packages.git"
lo:define_default_value LIBREROUTER_FEED "src-link librerouter $(dirname $(realpath ${BASH_SOURCE}))/packages"
lo:define_default_value TMATE_FEED "src-git tmate https://github.com/project-openwrt/openwrt-tmate.git"
lo:define_default_value KCONFIG_UTILS_DIR "$HOME/Development/kconfig-utils/"

## If defined and the directory exists will use this as custom netifd source tree
lo:define_default_value NETIFD_REPO_DIR "$HOME/Development/netifd/"

## If something unexpected happens fail early to detect and debug easier.
## This is not enough, once `while` loop and functions are involved so do your
## homework with proper error handling.
set -o errexit
set -o errtrace
set -o nounset

## Print debug message to stderr with reasonable "decoration"
function librerouteros:dbg()
{
	>&2 echo $(basename "${BASH_SOURCE}") $@;
}

function configure_libremesh()
{
	kconfig_unset CONFIG_PACKAGE_odhcpd-ipv6only
	kconfig_unset CONFIG_PACKAGE_dnsmasq
	kconfig_set CONFIG_PACKAGE_lime-system
	kconfig_set CONFIG_PACKAGE_lime-proto-anygw
	kconfig_set CONFIG_PACKAGE_lime-proto-babeld
	kconfig_set CONFIG_PACKAGE_lime-proto-batadv
	kconfig_set CONFIG_PACKAGE_lime-proto-wan
	kconfig_set CONFIG_PACKAGE_lime-hwd-openwrt-wan

	kconfig_set CONFIG_PACKAGE_shared-state
	kconfig_set CONFIG_PACKAGE_shared-state-async
	kconfig_set CONFIG_PACKAGE_shared-state-babeld_hosts
	kconfig_set CONFIG_PACKAGE_shared-state-bat_hosts
	kconfig_set CONFIG_PACKAGE_shared-state-dnsmasq_hosts
	kconfig_set CONFIG_PACKAGE_shared-state-dnsmasq_leases
	kconfig_set CONFIG_PACKAGE_shared-state-nodes_and_links

	local mNetifdGitSrc="$LIBREROUTEROS_BUILD_DIR/package/network/config/netifd/git-src"
	rm -f "$mNetifdGitSrc"
	[ "x$NETIFD_REPO_DIR" == "x" ] || [ ! -d "$NETIFD_REPO_DIR" ] ||
	{
		kconfig_set CONFIG_DEVEL
		kconfig_set CONFIG_SRC_TREE_OVERRIDE

		ln -s "$NETIFD_REPO_DIR/.git" "$mNetifdGitSrc"
	}
}

function configure_remove_unused_packages()
{
	kconfig_unset CONFIG_PACKAGE_ppp
	kconfig_unset CONFIG_PACKAGE_ppp-mod-pppoe
	kconfig_unset CONFIG_PACKAGE_kmod-ppp
	kconfig_unset CONFIG_PACKAGE_kmod-pppoe
	kconfig_unset CONFIG_PACKAGE_kmod-pppox
}

function configure_librerouteros()
{
	configure_libremesh
	configure_remove_unused_packages

	kconfig_set CONFIG_PACKAGE_lime-app
	kconfig_set CONFIG_PACKAGE_lime-docs-minimal

	kconfig_set CONFIG_PACKAGE_check-date-http
	kconfig_set CONFIG_PACKAGE_deferable-reboot
	kconfig_set CONFIG_PACKAGE_eupgrade

	kconfig_set CONFIG_PACKAGE_miniserver-client
	kconfig_set CONFIG_PACKAGE_safe-reboot
	
	kconfig_set CONFIG_IMAGEOPT # Needed by VERSIONOPT
	kconfig_set CONFIG_VERSIONOPT
	kconfig_set CONFIG_VERSION_BUG_URL '"https://gitlab.com/librerouter/librerouteros"'
	kconfig_set CONFIG_VERSION_CODE '""'
	kconfig_set CONFIG_VERSION_CODE_FILENAMES
	kconfig_set CONFIG_VERSION_DIST '"LibreRouterOs"'
	kconfig_set CONFIG_VERSION_FILENAMES
	kconfig_set CONFIG_VERSION_HOME_URL '"https://librerouter.org/"'
	kconfig_set CONFIG_VERSION_HWREV '""'
	kconfig_set CONFIG_VERSION_MANUFACTURER '"LibreRouterOs"'
	kconfig_set CONFIG_VERSION_MANUFACTURER_URL '"https://librerouter.org/"'
	kconfig_set CONFIG_VERSION_NUMBER '""'
	kconfig_set CONFIG_VERSION_PRODUCT '""'
	kconfig_set CONFIG_VERSION_REPO '""'
	kconfig_set CONFIG_VERSION_SUPPORT_URL '"https://foro.librerouter.org/"'
}

function configure_firstboot_wizard()
{
	kconfig_set CONFIG_PACKAGE_first-boot-wizard
}

function configure_atheros_radio_drivers()
{
	kconfig_set CONFIG_PACKAGE_ATH_DEBUG
	kconfig_set CONFIG_PACKAGE_ATH_DYNACK
	kconfig_set CONFIG_PACKAGE_wifi-unstuck-wa
}

function configure_build_log()
{
	kconfig_set CONFIG_DEVEL # Needed by BUILD_LOG
	kconfig_set CONFIG_BUILD_LOG
}

function configure_finalize()
{
	# G10h4ck 2023-09-02:
	# run `make defconfig` again to accomodate changes to the `.config` file,
	# this will also select needed dependencies and fix option ordering, which
	# is important for a proper build 
	make defconfig
	kconfig_check
	kconfig_wipe_register
}

function target_librerouter_v1()
{
	kconfig_init_register

	echo "" > "$KCONFIG_CONFIG_PATH"
	kconfig_set CONFIG_TARGET_ath79
	kconfig_set CONFIG_TARGET_ath79_generic
	kconfig_set CONFIG_TARGET_ath79_generic_DEVICE_librerouter_librerouter-v1

	# G10h4ck 2023-09-02:
	# Running `make defconfig` here to generate de default configuration is
	# necessary, otherwise the added packages configuration will be mangled
	# by the next run of `make defconfig` in an unrealiable manner
	make defconfig

	configure_atheros_radio_drivers
	configure_librerouteros
	configure_firstboot_wizard

	kconfig_set CONFIG_PACKAGE_safe-upgrade

	kconfig_set CONFIG_PACKAGE_kmod-usb-ledtrig-usbport
	kconfig_set CONFIG_PACKAGE_shared-state-persist

	kconfig_set CONFIG_PACKAGE_librerouter-1-hw-quircks

	configure_build_log
	configure_finalize
}

function target_ath79_generic_multiradio()
{
	kconfig_init_register
	echo "" > "$KCONFIG_CONFIG_PATH"

	kconfig_set CONFIG_TARGET_ath79
	kconfig_set CONFIG_TARGET_ath79_generic

	kconfig_set CONFIG_TARGET_MULTI_PROFILE
	kconfig_set CONFIG_TARGET_PER_DEVICE_ROOTFS
	kconfig_set CONFIG_TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wdr3500-v1
	kconfig_set CONFIG_TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wdr3600-v1
	kconfig_set CONFIG_TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wdr4300-v1

	# Enforce librerouter-v1 image is built only via it's specific target
	kconfig_unset CONFIG_TARGET_ath79_generic_DEVICE_librerouter_librerouter-v1

	# G10h4ck 2023-09-02:
	# Running `make defconfig` here to generate de default configuration is
	# necessary, otherwise the added packages configuration will be mangled
	# by the next run of `make defconfig` in an unrealiable manner
	make defconfig

	configure_atheros_radio_drivers
	configure_librerouteros
	configure_firstboot_wizard

	configure_build_log
	configure_finalize
}

function owrt_build()
{
	local MAKE_FLAGS="-j$(nproc)"

	if $BUILD_DEBUG; then
		MAKE_FLAGS="-j1 V=sc"
	fi

	make $MAKE_FLAGS download
	$BUILD_DOWNLOAD_ONLY || make $MAKE_FLAGS
}

function find_kernel_owrt_base_config()
{
	mArch=${1-ath79}
	kSourcePath="${LIBREROUTEROS_BUILD_DIR}/target/linux/${mArch}/"
	pushd "$kSourcePath" > /dev/null
	kConfigName="$(find -regextype posix-extended -regex '\./config-[0-9]+\.[0-9]+')"
	popd > /dev/null
	realpath "${kSourcePath}/${kConfigName}"
}

function prepare_target_buildroot()
{
	mkdir -p "$LIBREROUTEROS_BUILD_DIR"
	rm -rf "$LIBREROUTEROS_BUILD_DIR"
	cp --recursive --reflink=auto "$OPENWRT_SRC_DIR" "$LIBREROUTEROS_BUILD_DIR"

	pushd "$LIBREROUTEROS_BUILD_DIR" &> /dev/null

	mkdir -p "$OPENWRT_DL_DIR"
	unlink ./dl || rm -r ./dl || true
	ln -s "$OPENWRT_DL_DIR" ./dl

	cp ./feeds.conf.default ./feeds.conf
	echo "$LIBREMESH_FEED" >> ./feeds.conf
	echo "$LIBREROUTER_FEED" >> ./feeds.conf
	echo "$TMATE_FEED" >> ./feeds.conf

	./scripts/feeds update -a
	./scripts/feeds install -a

	popd &> /dev/null
}

export KCONFIG_CONFIG_PATH="${LIBREROUTEROS_BUILD_DIR}/.config"
source "$KCONFIG_UTILS_DIR/kconfig-utils.sh"


case "$BUILD_TARGET" in
hilink_hlk-7621a-evb)
	prepare_target_buildroot "$BUILD_TARGET"
	pushd "$LIBREROUTEROS_BUILD_DIR"

	echo "" > "$KCONFIG_CONFIG_PATH"
	kconfig_init_register

	kconfig_set CONFIG_TARGET_ramips
	kconfig_set CONFIG_TARGET_ramips_mt7621
	kconfig_set CONFIG_TARGET_ramips_mt7621_DEVICE_hilink_hlk-7621a-evb
	make defconfig

	kconfig_set CONFIG_PACKAGE_kmod-mt7916-firmware

	configure_librerouteros
	configure_build_log
	configure_finalize

	owrt_build

	$BUILD_DOWNLOAD_ONLY || ls -alh \
		bin/targets/ramips/mt7621/librerouteros-*-ramips-mt7621-hilink_hlk-7621a-evb-squashfs-sysupgrade.bin

	popd &> /dev/null
	;;
librerouter-r2)
	prepare_target_buildroot "$BUILD_TARGET"
	pushd "$LIBREROUTEROS_BUILD_DIR"

	echo "" > "$KCONFIG_CONFIG_PATH"
	# export KCONFIG_CONFIG_PATH="$(find_kernel_owrt_base_config)"
	kconfig_init_register
	# Disable kernel command line being read from device tree which is mutually
	# exclusive with reading it from boot loader
	# CONFIG_MIPS_CMDLINE_FROM_BOOTLOADER
	kconfig_unset CONFIG_MIPS_CMDLINE_FROM_DTB

	# safe-upgrade need kernel command line to be generated dinamically by the
	# boot loader (U-Boot) depending on which partition (either fw1 or fw2) it
	# need to boot
	kconfig_set CONFIG_MIPS_CMDLINE_FROM_BOOTLOADER

	# Enable pre-DTS (device tree) OpenWrt code do deal with MTD subpartition
	# split firmware (kernel+squashfs+jffs2), this is necessary because new DTS
	# based code doesn't support dual boot at all resulting in kernel being
	# loaded from fw2 but rootfs from from fw1
	# @see https://openwrt.org/docs/guide-developer/defining-firmware-partitions
	# @see https://openwrt.org/docs/techref/flash.layout
	# @see https://openwrt.org/docs/techref/filesystems
	# @see http://lists.openwrt.org/pipermail/openwrt-devel/2024-February/042201.html
	# @see http://lists.openwrt.org/pipermail/openwrt-devel/2024-February/042253.html
	kconfig_set CONFIG_MTD_SPLIT_FIRMWARE

	kconfig_set CONFIG_TARGET_ramips
	kconfig_set CONFIG_TARGET_ramips_mt7621
	kconfig_set CONFIG_TARGET_ramips_mt7621_DEVICE_librerouter_librerouter-r2
	make defconfig

	kconfig_set CONFIG_PACKAGE_kmod-mt7916-firmware

	# Support librerouter 1 radios
	kconfig_set CONFIG_PACKAGE_kmod-ath9k

	configure_librerouteros
	configure_build_log
	configure_finalize

	owrt_build

	$BUILD_DOWNLOAD_ONLY || ls -alh \
		bin/targets/ramips/mt7621/librerouteros-*-ramips-mt7621-librerouter_librerouter-r2-squashfs-sysupgrade.bin

	popd &> /dev/null
	;;
youhua_wr1200js)
	prepare_target_buildroot "$BUILD_TARGET"
	pushd "$LIBREROUTEROS_BUILD_DIR"

	echo "" > "$KCONFIG_CONFIG_PATH"
	kconfig_init_register

	kconfig_set CONFIG_TARGET_ramips
	kconfig_set CONFIG_TARGET_ramips_mt7621
	kconfig_set CONFIG_TARGET_ramips_mt7621_DEVICE_youhua_wr1200js
	make defconfig

	configure_librerouteros
	configure_build_log
	configure_finalize

	owrt_build

	$BUILD_DOWNLOAD_ONLY || ls -alh \
		bin/targets/ramips/mt7621/librerouteros-*-ramips-mt7621-youhua_wr1200js-squashfs-sysupgrade.bin

	popd &> /dev/null
	;;
librerouter-v1)
	prepare_target_buildroot "$BUILD_TARGET"
	pushd "$LIBREROUTEROS_BUILD_DIR"

	target_librerouter_v1

	# Add Linux Kernel options required for safe-upgrade
	# @see https://forum.openwrt.org/t/best-method-to-modify-kernel-config/165089
	export KCONFIG_CONFIG_PATH="$(find_kernel_owrt_base_config)"
	kconfig_init_register

	# Disable kernel command line being read from device tree which is mutually
	# exclusive with reading it from boot loader
	# CONFIG_MIPS_CMDLINE_FROM_BOOTLOADER
	kconfig_unset CONFIG_MIPS_CMDLINE_FROM_DTB

	# safe-upgrade need kernel command line to be generated dinamically by the
	# boot loader (U-Boot) depending on which partition (either fw1 or fw2) it
	# need to boot
	kconfig_set CONFIG_MIPS_CMDLINE_FROM_BOOTLOADER

	# Enable pre-DTS (device tree) OpenWrt code do deal with MTD subpartition
	# split firmware (kernel+squashfs+jffs2), this is necessary because new DTS
	# based code doesn't support dual boot at all resulting in kernel being
	# loaded from fw2 but rootfs from from fw1
	# @see https://openwrt.org/docs/guide-developer/defining-firmware-partitions
	# @see https://openwrt.org/docs/techref/flash.layout
	# @see https://openwrt.org/docs/techref/filesystems
	# @see http://lists.openwrt.org/pipermail/openwrt-devel/2024-February/042201.html
	# @see http://lists.openwrt.org/pipermail/openwrt-devel/2024-February/042253.html
	kconfig_set CONFIG_MTD_SPLIT_FIRMWARE

	owrt_build

	$BUILD_DOWNLOAD_ONLY ||
	{
		# Look for compiled Linux kernel .config
		mBuildDir="${LIBREROUTEROS_BUILD_DIR}/build_dir/target-mips_24kc_musl/linux-ath79_generic/"
		pushd "$mBuildDir"
		kBuildConfigPath="${mBuildDir}/$(find -regextype posix-extended -regex '\./linux-[0-9]+\.[0-9]+(\.[0-9]+)?/\.config')"
		popd

		# Check compiled Linux kernel configuration are constistent with
		# safe-upgrade requirements
		kconfig_check "$kBuildConfigPath"
		kconfig_wipe_register

		# Fail if the image wasn't created
		ls -alh bin/targets/ath79/generic/librerouteros-*-ath79-generic-librerouter_librerouter-v1-squashfs-sysupgrade.bin
	}

	popd &> /dev/null
	;;
ath79_generic_multiradio)
	prepare_target_buildroot "$BUILD_TARGET"
	pushd "$LIBREROUTEROS_BUILD_DIR"

	target_ath79_generic_multiradio
	owrt_build

	$BUILD_DOWNLOAD_ONLY || ls -alh \
		bin/targets/ath79/generic/librerouteros-*-ath79-generic-tplink_tl-wdr3500-v1-squashfs-sysupgrade.bin

	popd &> /dev/null
	;;
*)
	echo "Usage:
  $ $0 <TARGET>
Where target is one of the followings: librerouter-v1, ath79_generic,
hilink_hlk-7621a-evb, youhua_wr1200js
Set BUILD_DEBUG=true to run make with increased verbosity (-j1 V=sc)"
	exit 1
	;;
esac
