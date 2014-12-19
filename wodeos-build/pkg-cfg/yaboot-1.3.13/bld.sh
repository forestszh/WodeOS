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

PKG_URL="http://yaboot.ozlabs.org/releases/"
PKG_ZIP="yaboot-1.3.13.tar.gz"
PKG_SUM=""

PKG_TAR="yaboot-1.3.13.tar"
PKG_DIR="yaboot-1.3.13"


# Function Arguments:
#      $1 ... Package name, like "glibc-2.19".


# ******************************************************************************
# pkg_patch
# ******************************************************************************

pkg_patch() {

local patchDir="${TTYLINUX_PKGCFG_DIR}/$1/patch"
local patchFile=""

PKG_STATUS="init error"

#cd "${PKG_DIR}" # yaboot patches are applied above the dir.
for patchFile in "${patchDir}"/*; do
	[[ -r "${patchFile}" ]] && patch -p0 <"${patchFile}"
done
#cd ..

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

PKG_STATUS="make error"

cd "${PKG_DIR}"
source "${TTYLINUX_XTOOL_DIR}/_xbt_env_set"
PATH="${XBT_BIN_PATH}:${PATH}" make \
	CC="${XBT_CC} --sysroot=${TTYLINUX_SYSROOT_DIR}" \
	CROSS_COMPILE=${XBT_TARGET}- \
	LD=${XBT_LD} || return 1
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
	CC="${XBT_CC} --sysroot=${TTYLINUX_SYSROOT_DIR}" \
	CROSS_COMPILE=${XBT_TARGET}- \
	LD=${XBT_LD} \
	STRIP=${XBT_STRIP} \
	ROOT=${TTYLINUX_SYSROOT_DIR} \
	PREFIX=usr \
	MANDIR=share/man \
	install || return 1
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
