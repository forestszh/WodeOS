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

PKG_URL="http://ftp.gnu.org/gnu/ncurses/"
PKG_ZIP="ncurses-5.9.tar.gz"
PKG_SUM=""

PKG_TAR="ncurses-5.9.tar"
PKG_DIR="ncurses-5.9"


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

local ENABLE_WIDEC="--enable-widec"
local WITHOUT_CXX=""

PKG_STATUS="./configure error"

cd "${PKG_DIR}"

mv misc/terminfo.src misc/terminfo.src-ORIG
cp ${TTYLINUX_PKGCFG_DIR}/$1/terminfo.src misc/terminfo.src

source "${TTYLINUX_XTOOL_DIR}/_xbt_env_set"
if [[ x"${XBT_C_PLUS_PLUS}" == x"no" ]]; then
	WITHOUT_CXX="--without-cxx --without-cxx-bindings"
fi

if [[ "${TTYLINUX_PLATFORM}" == "wrtu54g_tm" ]]; then
	ENABLE_WIDEC=""
fi

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
	--libdir=/lib \
	--mandir=/usr/share/man \
	--enable-shared \
	--enable-overwrite \
	${ENABLE_WIDEC} \
	--disable-largefile \
	--disable-termcap \
	--with-build-cc=gcc \
	--with-install-prefix=${TTYLINUX_SYSROOT_DIR} \
	--with-shared \
	--without-ada \
	${WITHOUT_CXX} \
	--without-debug \
	--without-gpm \
	--without-normal || return 1
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

PATH="${XBT_BIN_PATH}:${PATH}" make install || return 1

# *****************************************************************************
# This is the install results; it is not what I want.
#
# sysroot/usr/bin/captoinfo -> tic*
# sysroot/usr/bin/clear*
# sysroot/usr/bin/infocmp*
# sysroot/usr/bin/infotocap -> tic*
# sysroot/usr/bin/ncursesw5-config*
# sysroot/usr/bin/reset -> tset*
# sysroot/usr/bin/tabs*
# sysroot/usr/bin/tic*
# sysroot/usr/bin/toe*
# sysroot/usr/bin/tput*
# sysroot/usr/bin/tset*
#
# sysroot/lib/libformw.so -> libformw.so.5*
# sysroot/lib/libformw.so.5 -> libformw.so.5.9*
# sysroot/lib/libformw.so.5.9*
# sysroot/lib/libmenuw.so -> libmenuw.so.5*
# sysroot/lib/libmenuw.so.5 -> libmenuw.so.5.9*
# sysroot/lib/libmenuw.so.5.9*
# sysroot/lib/libncurses++w.a
# sysroot/lib/libncursesw.so -> libncursesw.so.5*
# sysroot/lib/libncursesw.so.5 -> libncursesw.so.5.9*
# sysroot/lib/libncursesw.so.5.9*
# sysroot/lib/libpanelw.so -> libpanelw.so.5*
# sysroot/lib/libpanelw.so.5 -> libpanelw.so.5.9*
# sysroot/lib/libpanelw.so.5.9*
#
# sysroot/usr/lib/terminfo -> ../share/terminfo/
# *****************************************************************************

if [[ "${TTYLINUX_PLATFORM}" != "wrtu54g_tm" ]]; then

	# Move any .a files from /lib to /usr/lib; there seems to be only
	# one .a file: libncurses++w.a
	#
	_sysroot=${TTYLINUX_SYSROOT_DIR}
	mv ${_sysroot}/lib/libncurses++w.a ${_sysroot}/usr/lib/
	unset _sysroot

	_usrlib="${TTYLINUX_SYSROOT_DIR}/usr/lib"

	# Many applications expect the linker to find non-wide character
	# ncurses libraries; make them link with wide-character libraries by
	# way of linker scripts.
	#
	for _lib in form menu ncurses panel ; do
		rm --force --verbose      ${_usrlib}/lib${_lib}.so
		echo "INPUT(-l${_lib}w)" >${_usrlib}/lib${_lib}.so
	done; unset _lib

	# Do something about builds that look for -lcurses, -lcursesw
	# and -ltinfo.
	#
	rm --force --verbose      ${_usrlib}/libcursesw.so
	echo "INPUT(-lncursesw)" >${_usrlib}/libcursesw.so
	rm --force --verbose      ${_usrlib}/libcurses.so
	echo "INPUT(-lncursesw)" >${_usrlib}/libcurses.so
	ln --force --symbolic libncurses.so ${_usrlib}/libtinfo.so.5
	ln --force --symbolic libtinfo.so.5 ${_usrlib}/libtinfo.so

	unset _usrlib

fi

if [[ "${TTYLINUX_PLATFORM}" == "wrtu54g_tm" ]]; then

	_usrlib="${TTYLINUX_SYSROOT_DIR}/usr/lib"

	# Many applications expect the linker to find non-wide character
	# ncurses libraries; make them link with wide-character libraries by
	# way of linker scripts.
	#
	for _lib in form menu ncurses panel ; do
		rm --force --verbose      ${_usrlib}/lib${_lib}.so
		echo "INPUT(-l${_lib}w)" >${_usrlib}/lib${_lib}.so
	done; unset _lib

	# Do something about builds that look for -lcurses, -lcursesw
	# and -ltinfo.
	#
	rm --force --verbose     ${_usrlib}/libcurses.so
	echo "INPUT(-lncurses)" >${_usrlib}/libcurses.so
	ln --force --symbolic libncurses.so ${_usrlib}/libtinfo.so.5
	ln --force --symbolic libtinfo.so.5 ${_usrlib}/libtinfo.so

	unset _usrlib

fi

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
