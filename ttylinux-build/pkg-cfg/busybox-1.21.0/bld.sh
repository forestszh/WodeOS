#!/bin/bash


# This file is part of the ttylinux software.
# The license which this software falls under is GPLv2 as follows:
#
# Copyright (C) 2010-2013 Douglas Jerome <douglas@ttylinux.org>
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 2 of the License, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 59 Temple
# Place, Suite 330, Boston, MA  02111-1307  USA


# ******************************************************************************
# Definitions
# ******************************************************************************

PKG_URL="http://www.busybox.net/downloads/"
PKG_ZIP="busybox-1.21.0.tar.bz2"
PKG_SUM=""

PKG_TAR="busybox-1.21.0.tar"
PKG_DIR="busybox-1.21.0"


# Function Arguments:
#      $1 ... Package name, like "glibc-2.19".


# ******************************************************************************
# pkg_patch
# ******************************************************************************

pkg_patch() {

local patchDir="${TTYLINUX_PKGCFG_DIR}/$1/patch"
local patchFile=""

PKG_STATUS="init error"

cd "${PKG_DIR}"
for patchFile in "${patchDir}"/*; do
	[[ -r "${patchFile}" ]] && patch -p1 <"${patchFile}"
done
cd ..

PKG_STATUS=""
return 0

}


# ******************************************************************************
# pkg_configure
# ******************************************************************************

pkg_configure() {
PKG_STATUS=""
return 0
}


# ******************************************************************************
# pkg_make
# ******************************************************************************

pkg_make() {

local cfgDir="${TTYLINUX_PKGCFG_DIR}/$1"
local cfg=""
local SKIP_STRIP_FLAG=""

if [[ x"${TTYLINUX_STRIP_BINS:-}" == x"" ]]; then
	SKIP_STRIP_FLAG=y
fi

cd "${PKG_DIR}"
source "${TTYLINUX_XTOOL_DIR}/_xbt_env_set"

# *****                             *****
# ***** Build and Install - No SUID *****
# *****                             *****

cfg="${cfgDir}/_bbox-stnd.cfg"
if [[ x"${TTYLINUX_PACKAGE_BUSYBOX_HAS_LOSETUP:-}" == x"y" ]]; then
	cfg="${cfgDir}/_bbox-stnd-losetup.cfg"
fi
if [[ -f "${cfg}" ]]; then
	cp "${cfg}" .config
else
	PKG_STATUS="No $1 bbox-stnd config file"
	return 1
fi

PKG_STATUS="make error"
# Remove the --jobs=${NJOBS} make option to make sense of the build log file
# for debugging.
CFLAGS="${TTYLINUX_CFLAGS} --sysroot=${TTYLINUX_SYSROOT_DIR}" \
PATH="${XBT_BIN_PATH}:${PATH}" make \
	--jobs=${NJOBS} \
	ARCH="${TTYLINUX_CPU}" \
	CROSS_COMPILE="${XBT_TARGET}-" \
	CONFIG_PREFIX=${TTYLINUX_SYSROOT_DIR} \
	SKIP_STRIP=${SKIP_STRIP_FLAG} \
	V=1 || return 1

PKG_STATUS="make install error"
# CFLAGS, ARCH and CROSS_COMPILE seem to be needed to make install.
# Change the location of awk.
#
CFLAGS="${TTYLINUX_CFLAGS}  --sysroot=${TTYLINUX_SYSROOT_DIR}" \
PATH="${XBT_BIN_PATH}:${PATH}" make \
	ARCH="${TTYLINUX_CPU}" \
	CROSS_COMPILE="${XBT_TARGET}-" \
	CONFIG_PREFIX=${TTYLINUX_SYSROOT_DIR} \
	install || return 1
mv "${TTYLINUX_SYSROOT_DIR}/usr/bin/awk" "${TTYLINUX_SYSROOT_DIR}/bin/awk"

make distclean # Roll-play like nothing happened.

# *****                               *****
# ***** Build and Install - With SUID *****
# *****                               *****


cfg="${cfgDir}/_bbox-suid.cfg"
if [[ -f "${cfg}" ]]; then
	cp "${cfg}" .config
else
	PKG_STATUS="No $1 bbox-suid config file"
	return 1
fi

PKG_STATUS="make error"
# Remove the --jobs=${NJOBS} make option to make sense of the build log file
# for debugging.
CFLAGS="${TTYLINUX_CFLAGS} --sysroot=${TTYLINUX_SYSROOT_DIR}" \
PATH="${XBT_BIN_PATH}:${PATH}" make \
	--jobs=${NJOBS} \
	ARCH="${TTYLINUX_CPU}" \
	CROSS_COMPILE="${XBT_TARGET}-" \
	CONFIG_PREFIX=${TTYLINUX_SYSROOT_DIR} \
	SKIP_STRIP=${SKIP_STRIP_FLAG} \
	V=1 || return 1

# Install busybox suid files.
#
rm -f "${TTYLINUX_SYSROOT_DIR}/bin/busybox-suid"
rm -f "${TTYLINUX_SYSROOT_DIR}/bin/mount"
rm -f "${TTYLINUX_SYSROOT_DIR}/bin/ping"
rm -f "${TTYLINUX_SYSROOT_DIR}/bin/su"
rm -f "${TTYLINUX_SYSROOT_DIR}/bin/umount"
rm -f "${TTYLINUX_SYSROOT_DIR}/usr/bin/crontab"
rm -f "${TTYLINUX_SYSROOT_DIR}/usr/bin/passwd"
rm -f "${TTYLINUX_SYSROOT_DIR}/usr/bin/traceroute"

bbsuid="${TTYLINUX_SYSROOT_DIR}/bin/busybox-suid"
install --mode=4711 --owner=0 --group=0 busybox "${bbsuid}"
link "${bbsuid}" "${TTYLINUX_SYSROOT_DIR}/bin/mount"
link "${bbsuid}" "${TTYLINUX_SYSROOT_DIR}/bin/ping"
link "${bbsuid}" "${TTYLINUX_SYSROOT_DIR}/bin/su"
link "${bbsuid}" "${TTYLINUX_SYSROOT_DIR}/bin/umount"
link "${bbsuid}" "${TTYLINUX_SYSROOT_DIR}/usr/bin/crontab"
link "${bbsuid}" "${TTYLINUX_SYSROOT_DIR}/usr/bin/passwd"
link "${bbsuid}" "${TTYLINUX_SYSROOT_DIR}/usr/bin/traceroute"
unset bbsuid

source "${TTYLINUX_XTOOL_DIR}/_xbt_env_clr"
cd ..

PKG_STATUS=""
return 0

}


# ******************************************************************************
# pkg_install
# ******************************************************************************

pkg_install() {

PKG_STATUS="make install error"

if [[ -d "rootfs/" ]]; then
	find "rootfs/" ! -type d -exec touch {} \;
	cp --archive --force rootfs/* "${TTYLINUX_SYSROOT_DIR}"
fi

for f in ${TTYLINUX_SYSROOT_DIR}/etc/issue*; do
	if [[ -f "${f}" ]]; then
		sedCmd="sed --in-place ${f}"
		${sedCmd} --expression="s/TTYLINUX_VERSION/${TTYLINUX_VERSION}/"
		${sedCmd} --expression="s/TTYLINUX_NAME/${TTYLINUX_NAME}/"
		${sedCmd} --expression="s/^.m/${TTYLINUX_CPU}/"
		unset sedCmd
	fi
done
unset f

modprobeFile="${TTYLINUX_SYSROOT_DIR}/etc/modprobe.d/modprobe.conf"
case "${TTYLINUX_PLATFORM}" in
	'mac_g4')
		sed --in-place "${modprobeFile}" --expression="s/#nomac /# /"
		sed --in-place "${TTYLINUX_SYSROOT_DIR}/etc/modtab" \
			--expression="s/# snd-powermac/snd-powermac/"
		;;
	*)
		sed --in-place "${modprobeFile}" --expression="s/#nomac //"
		;;
esac
unset modprobeFile

PKG_STATUS=""
return 0

}


# ******************************************************************************
# pkg_clean
# ******************************************************************************

pkg_clean() {
PKG_STATUS=""
return 0
}


# end of file
