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

PKG_URL="http://ftp.gnu.org/gnu/gcc/gcc-4.7.2/ ftp://sourceware.org/pub/gcc/releases/gcc-4.6.3/"
PKG_ZIP="gcc-4.6.3.tar.bz2"
PKG_SUM=""

PKG_TAR="gcc-4.6.3.tar"
PKG_DIR="gcc-4.6.3"


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

# Suppress the installation of libiberty.a; it is provided by binutils.
#
sed -i 's/install_to_$(INSTALL_DEST) //' libiberty/Makefile.in

# Pure 64-bit fixups.
#
if [[ "${TTYLINUX_CPU}" = "x86_64" ]]; then
	# On x86_64, unsetting the multilib spec for GCC ensures that it won't
	# attempt to link against libraries on the host.
	for file in $(find gcc/config -name t-linux64) ; do
		sed -e '/MULTILIB_OSDIRNAMES/d' -i "${file}"
	done
	unset file
fi

cd ..

rm --force --recursive "build-gcc"
mkdir "build-gcc"

PKG_STATUS=""
return 0

}


# ******************************************************************************
# pkg_configure
# ******************************************************************************

pkg_configure() {

local ENABLE_LANGUAGES="--enable-languages=c"
local ENABLE__CXA_ATEXIT=""
local ENABLE_THREADS="--enable-threads=no"

PKG_STATUS="./configure error"

cd "build-gcc"
source "${TTYLINUX_XTOOL_DIR}/_xbt_env_set"

if [[ "${XBT_C_PLUS_PLUS}" = "yes" ]]; then
	ENABLE_LANGUAGES="--enable-languages=c,c++"
	ENABLE__CXA_ATEXIT="--enable-__cxa_atexit"
fi
if [[ "${XBT_THREAD_MODEL}" = "nptl" ]];then
	ENABLE_THREADS="--enable-threads=posix"
fi

# Only the C compiler is enabled.
#
ENABLE_LANGUAGES="--enable-languages=c"
ENABLE__CXA_ATEXIT=""

AR=${XBT_AR} \
AS="${XBT_AS} --sysroot=${TTYLINUX_SYSROOT_DIR}" \
CC="${XBT_CC} --sysroot=${TTYLINUX_SYSROOT_DIR}" \
CXX="${XBT_CXX} --sysroot=${TTYLINUX_SYSROOT_DIR}" \
LD="${XBT_LD} --sysroot=${TTYLINUX_SYSROOT_DIR}" \
NM=${XBT_NM} \
OBJCOPY=${XBT_OBJCOPY} \
RANLIB=${XBT_RANLIB} \
SIZE=${XBT_SIZE} \
STRIP=${XBT_STRIP} \
CFLAGS="${TTYLINUX_CFLAGS}" \
../${PKG_DIR}/configure \
	--build=${MACHTYPE} \
	--host=${XBT_TARGET} \
	--target=${XBT_TARGET} \
	--prefix=/usr \
	--infodir=/usr/share/info \
	--mandir=/usr/share/man \
	${ENABLE_LANGUAGES} \
	--enable-c99 \
	--enable-clocale=gnu \
	--enable-long-long \
	--enable-shared \
	--enable-symvers=gnu \
	${ENABLE_THREADS} \
	${ENABLE__CXA_ATEXIT} \
	--disable-bootstrap \
	--disable-libada \
	--disable-libgomp \
	--disable-libmudflap \
	--disable-libssp \
	--disable-libstdcxx-pch \
	--disable-lto \
	--disable-multilib \
	--disable-nls \
	--with-build-sysroot=${TTYLINUX_SYSROOT_DIR} \
	--with-gmp=${TTYLINUX_SYSROOT_DIR}/usr \
	--with-mpc=${TTYLINUX_SYSROOT_DIR}/usr \
	--with-mpfr=${TTYLINUX_SYSROOT_DIR}/usr || return 1

#LDFLAGS="-lm -lstdc++" \
#	--enable-cloog-backend=isl \
#	--disable-target-libiberty \
#	--disable-target-zlib \
#	--with-cloog=${TTYLINUX_SYSROOT_DIR}/usr \
#	--with-ppl=${TTYLINUX_SYSROOT_DIR}/usr || return 1

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

cd "build-gcc"
source "${TTYLINUX_XTOOL_DIR}/_xbt_env_set"
NJOBS=1
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

cd "build-gcc"
source "${TTYLINUX_XTOOL_DIR}/_xbt_env_set"
PATH="${XBT_BIN_PATH}:${PATH}" make \
	DESTDIR=${TTYLINUX_SYSROOT_DIR} \
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
rm --force --recursive "build-gcc"
return 0
}


# end of file
