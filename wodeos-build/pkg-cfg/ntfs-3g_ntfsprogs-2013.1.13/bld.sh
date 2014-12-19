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

PKG_URL="http://tuxera.com/opensource/"
PKG_ZIP="ntfs-3g_ntfsprogs-2013.1.13.tgz"
PKG_SUM=""

PKG_TAR="ntfs-3g_ntfsprogs-2013.1.13.tar"
PKG_DIR="ntfs-3g_ntfsprogs-2013.1.13"


# Function Arguments:
#      $1 ... Package name, like "glibc-2.19".


# ******************************************************************************
# pkg_patch
# ******************************************************************************

pkg_patch() {
PKG_STATUS=""
return 0
}


# ******************************************************************************
# pkg_configure
# ******************************************************************************

pkg_configure() {

PKG_STATUS="./configure error"

cd "${PKG_DIR}"
source "${TTYLINUX_XTOOL_DIR}/_xbt_env_set"
AR="${XBT_AR}" \
AS="${XBT_AS} --sysroot=${TTYLINUX_SYSROOT_DIR}" \
CC="${XBT_CC} --sysroot=${TTYLINUX_SYSROOT_DIR}" \
CXX="${XBT_CXX} --sysroot=${TTYLINUX_SYSROOT_DIR}" \
LD="${XBT_LD} --sysroot=${TTYLINUX_SYSROOT_DIR}" \
NM="${XBT_NM}" \
OBJCOPY="${XBT_OBJCOPY}" \
RANLIB="${XBT_RANLIB}" \
SIZE="${XBT_SIZE}" \
STRIP="${XBT_STRIP}" \
CFLAGS="${TTYLINUX_CFLAGS}" \
./configure \
	--build=${MACHTYPE} \
	--host=${XBT_TARGET} \
	--prefix=/usr \
	--enable-shared \
	--disable-static \
	--disable-ldconfig || return 1

source "${TTYLINUX_XTOOL_DIR}/_xbt_env_clr"
cd ..

PKG_STATUS=""
return 0

}


# ******************************************************************************
# pkg_make
# ******************************************************************************

pkg_make() {

PKG_STATUS="make error"

cd "${PKG_DIR}"
source "${TTYLINUX_XTOOL_DIR}/_xbt_env_set"
PATH="${XBT_BIN_PATH}:${PATH}" make \
	--jobs=${NJOBS} \
	CROSS_COMPILE=${XBT_TARGET}- || return 1
source "${TTYLINUX_XTOOL_DIR}/_xbt_env_clr"
cd ..

PKG_STATUS=""
return 0

}


# ******************************************************************************
# pkg_install
# ******************************************************************************

pkg_install() {

PKG_STATUS="install error"

cd "${PKG_DIR}"
source "${TTYLINUX_XTOOL_DIR}/_xbt_env_set"
PATH="${XBT_BIN_PATH}:${PATH}" make \
	DESTDIR=${TTYLINUX_SYSROOT_DIR} \
	install || return 1
rm --force ${TTYLINUX_SYSROOT_DIR}/sbin/mkfs.ntfs
rm --force ${TTYLINUX_SYSROOT_DIR}/sbin/mount.ntfs-3g
rm --force ${TTYLINUX_SYSROOT_DIR}/sbin/mount.lowntfs-3g
rm --force ${TTYLINUX_SYSROOT_DIR}/usr/lib/libntfs-3g.so
_lnk="ln --symbolic"
${_lnk} ../usr/sbin/mkntfs ${TTYLINUX_SYSROOT_DIR}/sbin/mkfs.ntfs
${_lnk} ../bin/ntfs-3g     ${TTYLINUX_SYSROOT_DIR}/sbin/mount.ntfs-3g
${_lnk} ../bin/lowntfs-3g  ${TTYLINUX_SYSROOT_DIR}/sbin/mount.lowntfs-3g
${_lnk} libntfs-3g.so.84   ${TTYLINUX_SYSROOT_DIR}/usr/lib/libntfs-3g.so
unset _lnk
source "${TTYLINUX_XTOOL_DIR}/_xbt_env_clr"
cd ..

if [[ -d "rootfs/" ]]; then
	find "rootfs/" ! -type d -exec touch {} \;
	cp --archive --force rootfs/* "${TTYLINUX_SYSROOT_DIR}"
fi

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
