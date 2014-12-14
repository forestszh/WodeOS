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

PKG_URL="(cross-tools)"
PKG_ZIP="(none)"
PKG_SUM=""

PKG_TAR="(none)"
PKG_DIR="(none)"


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
PKG_STATUS=""
return 0
}


# ******************************************************************************
# pkg_make
# ******************************************************************************

pkg_make() {
PKG_STATUS=""
return 0
}


# ******************************************************************************
# pkg_install
# ******************************************************************************

pkg_install() {

local xtoolTargDir="${TTYLINUX_XTOOL_DIR}/target"

PKG_STATUS="install error"

echo "Copying cross-tool $1 target components to sysroot."
cp --no-dereference --recursive ${xtoolTargDir}/* ${TTYLINUX_SYSROOT_DIR}

echo "Copying $1 ttylinux-specific components to sysroot."
if [[ -d "rootfs/" ]]; then
	find "rootfs/" ! -type d -exec touch {} \;
	cp --archive --force rootfs/* "${TTYLINUX_SYSROOT_DIR}"
fi

echo "Recording build information in the target, build-root/etc/ttylinux-xxx."
echo "$(uname -m)"            >"${TTYLINUX_SYSROOT_DIR}/etc/ttylinux-build"
echo "${TTYLINUX_TARGET_TAG}" >"${TTYLINUX_SYSROOT_DIR}/etc/ttylinux-target"

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
