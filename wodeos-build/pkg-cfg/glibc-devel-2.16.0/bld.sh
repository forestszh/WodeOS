#!/bin/bash


# This file is part of the ttylinux software.
# The license which this software falls under is as follows:
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

local dir="${TTYLINUX_PKGCFG_DIR}/$1"
local fileList="${dir}/files-${TTYLINUX_PLATFORM}"

PKG_STATUS=""

rm --force "${fileList}"

find "${TTYLINUX_SYSROOT_DIR}/usr/include" -type f | sort >"${fileList}"
sed --expression="s#${TTYLINUX_SYSROOT_DIR}/##" --in-place "${fileList}"
sed --expression="/\.install/d"                 --in-place "${fileList}"
sed --expression="/\.\.install\.cmd/d"          --in-place "${fileList}"
cat "${dir}/files.common" >>"${fileList}"
chmod 666 "${fileList}"

return 0

}


# ******************************************************************************
# pkg_install
# ******************************************************************************

pkg_install() {

local xtoolTargDir="${TTYLINUX_XTOOL_DIR}/target"

PKG_STATUS="install error"

echo "Copying cross-tool $1 target components to build-root."
_targDir=${TTYLINUX_SYSROOT_DIR}
cp --no-dereference ${xtoolTargDir}/usr/lib/*.a ${_targDir}/usr/lib
cp --no-dereference ${xtoolTargDir}/usr/lib/*.o ${_targDir}/usr/lib
cp --no-dereference --recursive \
	${xtoolTargDir}/usr/include/* \
	${_targDir}/usr/include
unset _targDir

echo "Copying $1 ttylinux-specific components to build-root."
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
