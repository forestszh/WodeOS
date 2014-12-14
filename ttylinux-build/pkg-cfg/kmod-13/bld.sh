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

PKG_URL="http://www.kernel.org/pub/linux/utils/kernel/kmod/"
PKG_ZIP="kmod-13.tar.bz2"
PKG_SUM=""

PKG_TAR="kmod-13.tar"
PKG_DIR="kmod-13"


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
	--bindir=/bin \
	--libdir=/lib \
	--sysconfdir=/etc \
	--without-xz \
	--without-zlib || return 1
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
	CROSS_COMPILE=${XBT_TARGET}- \
	DESTDIR=${TTYLINUX_SYSROOT_DIR} \
	INSTALL=install \
	install || return 1
source "${TTYLINUX_XTOOL_DIR}/_xbt_env_clr"
cd ..

rm --force ${TTYLINUX_SYSROOT_DIR}/sbin/depmod
rm --force ${TTYLINUX_SYSROOT_DIR}/sbin/insmod
rm --force ${TTYLINUX_SYSROOT_DIR}/sbin/modinfo
rm --force ${TTYLINUX_SYSROOT_DIR}/sbin/modprobe
rm --force ${TTYLINUX_SYSROOT_DIR}/sbin/rmmod
rm --force ${TTYLINUX_SYSROOT_DIR}/bin/lsmod

ln --symbolic ../bin/kmod ${TTYLINUX_SYSROOT_DIR}/sbin/depmod
ln --symbolic ../bin/kmod ${TTYLINUX_SYSROOT_DIR}/sbin/insmod
ln --symbolic ../bin/kmod ${TTYLINUX_SYSROOT_DIR}/sbin/modinfo
ln --symbolic ../bin/kmod ${TTYLINUX_SYSROOT_DIR}/sbin/modprobe
ln --symbolic ../bin/kmod ${TTYLINUX_SYSROOT_DIR}/sbin/rmmod
ln --symbolic kmod        ${TTYLINUX_SYSROOT_DIR}/bin/lsmod

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
