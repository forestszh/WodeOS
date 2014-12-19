#!/bin/bash


# This file is part of the ttylinux software.
# The license which this software falls under is GPLv2 as follows:
#
# Copyright (C) 2008-2012 Douglas Jerome <douglas@ttylinux.org>
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


# *****************************************************************************
#
# PROGRAM DESCRIPTION
#
#	This script has general startup and functions.
#
# CHANGE LOG
#
#	08may13	drj	Added kernel getting and patching functions.
#	23apr13	drj	Released files to be named with the platform, not CPU.
#	13mar12	drj	Hide ttylinux_target_umount stderr.
#	08mar12	drj	Finally set ncpus to something.
#	15feb12	drj	Rewrite for build process reorganization.
#	03mar11	drj	Added TTYLINUX_TAR_NAME
#	21jan11	drj	Conditional "ws-" prefix for the IMG and ISO file names.
#	06jan11	drj	Added TTYLINUX_SITE_DIR
#	01jan11	drj	Updated for TTYLINUX_CLASS, ttylinux-config.sh changes.
#	15dec10	drj	Updated to get package list from new file name.
#	11dec10	drj	Added comments.
#	11dec10	drj	Made build_config_setup() more specific.
#	11dec10	drj	Changed to use new platform directory structure.
#	16nov10	drj	Miscellaneous fussing.
#	08oct10	drj	Minor simplifications.
#	02apr10	drj	Did organizational changes for the embedded systems.
#	05mar10	drj	Removed ttylinux.site-config.sh
#	07oct08	drj	File creation.
#
# *****************************************************************************


# *************************************************************************** #
#                                                                             #
# S U B R O U T I N E S                                                       #
#                                                                             #
# *************************************************************************** #


# *****************************************************************************
# Check script environment.
# *****************************************************************************

dist_root_check() {

if [[ $(id -u) -ne 0 ]]; then
	echo "E> Only root can do this (scary)." >&2
	return 1
fi

if [[ $(id -g) -ne 0 ]]; then
	echo "E> Must be in the root group, not the $(id -gn) group." >&2
	echo "E> Try using 'newgrp - root'." >&2
	return 1
fi

return 0

}


# *****************************************************************************
# Check the distribution specifications.
# *****************************************************************************

dist_config_setup() {

TTYLINUX_CPU=${TTYLINUX_XBT%%-*}
TTYLINUX_TARGET_TAG="${TTYLINUX_VERSION}-${TTYLINUX_CPU}-${TTYLINUX_PLATFORM}"

TTYLINUX_DIR="$(pwd)"
TTYLINUX_BOOTLOADER_DIR="${TTYLINUX_DIR}/bootloader"
TTYLINUX_BUILD_DIR="${TTYLINUX_DIR}/build"
TTYLINUX_CONFIG_DIR="${TTYLINUX_DIR}/config"
TTYLINUX_DOC_DIR="${TTYLINUX_DIR}/doc"
TTYLINUX_IMG_DIR="${TTYLINUX_DIR}/img"
TTYLINUX_MNT_DIR="${TTYLINUX_DIR}/mnt"
TTYLINUX_PKGBIN_DIR="${TTYLINUX_DIR}/pkg-bin"
TTYLINUX_PKGBLD_DIR="${TTYLINUX_DIR}/pkg-bld"
TTYLINUX_PKGCFG_DIR="${TTYLINUX_DIR}/pkg-cfg"
TTYLINUX_PKGSRC_DIR="${TTYLINUX_DIR}/pkg-src"
TTYLINUX_PLATFORM_DIR="${TTYLINUX_DIR}/config/platform-${TTYLINUX_PLATFORM}"
TTYLINUX_SCRIPT_DIR="${TTYLINUX_DIR}/scripts"
TTYLINUX_SITE_DIR="${TTYLINUX_DIR}/site"
TTYLINUX_SYSROOT_DIR="${TTYLINUX_DIR}/sysroot"
TTYLINUX_VAR_DIR="${TTYLINUX_DIR}/var"

nameTag="${TTYLINUX_PLATFORM}-${TTYLINUX_VERSION}"
TTYLINUX_IMG_NAME="${TTYLINUX_DIR}/img/file_sys-${nameTag}.img"
TTYLINUX_IRD_NAME="${TTYLINUX_DIR}/img/initrd-${nameTag}"
TTYLINUX_TAR_NAME="${TTYLINUX_DIR}/img/ttylinux-${nameTag}.tar.bz2"
TTYLINUX_SRC_NAME="${TTYLINUX_DIR}/img/ttylinux-${nameTag}-src.iso"
TTYLINUX_ISO_NAME="${TTYLINUX_DIR}/img/ttylinux-${nameTag}.iso"
unset nameTag

return 0

}


# *****************************************************************************
# Check the distribution specifications.
# *****************************************************************************

build_config_setup() {

# This functions sets:
#
# TTYLINUX_XTOOL_DIR = ${TTYLINUX_XBT_DIR}/${TTYLINUX_XBT}
# XBT_LINUX_ARCH ...... set from ${TTYLINUX_XTOOL_DIR}/_versions
# XBT_LINUX_VER ....... set from ${TTYLINUX_XTOOL_DIR}/_versions
# XBT_LIBC_VER ........ set from ${TTYLINUX_XTOOL_DIR}/_versions
# XBT_XBINUTILS_VER ... set from ${TTYLINUX_XTOOL_DIR}/_versions
# XBT_XGCC_VER ........ set from ${TTYLINUX_XTOOL_DIR}/_versions

local err=0
local xtooldir=""

# Check for the cross-tool chain and load the cross-tool components' versions,
# if they can be found.  Set the cross-tool directory variable,
# TTYLINUX_XTOOL_DIR, here.
#
set +u
xtooldir="${TTYLINUX_DIR}/${TTYLINUX_XBT_DIR}/${TTYLINUX_XBT}"
if [[ ! -d "${xtooldir}" ]]; then
	echo "E> ${TTYLINUX_XBT} cross-tool chain not found." >&2
	return 1
fi
if [[ ! -f "${xtooldir}/_versions" ]]; then
	echo "E> ${TTYLINUX_XBT} cross-tool chain is broken." >&2
	echo "E> no ${xtooldir}/_versions file" >&2
	return 1
fi
TTYLINUX_XTOOL_DIR=${xtooldir}
source "${TTYLINUX_XTOOL_DIR}/_versions"
[[ -z "${XBT_LINUX_ARCH}"    ]] && err=1
[[ -z "${XBT_LINUX_VER}"     ]] && err=1
[[ -z "${XBT_LIBC_VER}"      ]] && err=1
[[ -z "${XBT_XBINUTILS_VER}" ]] && err=1
[[ -z "${XBT_XGCC_VER}"      ]] && err=1
if [[ ${err} -eq 1 ]]; then
	echo "E> Error in ${TTYLINUX_XTOOL_DIR}/_versions." >&2
	return 1
fi
set -u

kver="${TTYLINUX_USER_KERNEL:-${XBT_LINUX_VER##*-}}"
srcd="${TTYLINUX_XTOOL_DIR}/_pkg-src"
kcfg="${TTYLINUX_PLATFORM_DIR}/kernel-${kver}-${TTYLINUX_CONFIG}"
if [[ -n "${TTYLINUX_USER_KERNEL:-}" ]]; then
	srcd="${TTYLINUX_DIR}/site/platform-${TTYLINUX_PLATFORM}"
	kcfg="${srcd}/kernel-${TTYLINUX_USER_KERNEL}.cfg"
fi
TTYLINUX_KERNEL_SRCDIR="${srcd}"
TTYLINUX_KERNEL_CONFIG="${kcfg}"
unset kver
unset kcfg
unset srcd

return 0

}


# *****************************************************************************
# Mount the target filesystem.
# *****************************************************************************

build_spec_show() {

# Report on what we think we are doing.
#
echo "=> ttylinux project directory:"
echo "   ${TTYLINUX_DIR}"
echo "=> ttylinux-${TTYLINUX_VERSION} [${TTYLINUX_NAME}]"
echo "=> with ${TTYLINUX_XBT} cross-tool chain"
echo "=> with ${TTYLINUX_CPU} cross-building Binutils ${XBT_XBINUTILS_VER}"
echo "=> with ${TTYLINUX_CPU} cross-building GCC ${XBT_XGCC_VER}"
echo "=> with libc ${XBT_LIBC_VER}, kernel interface:"
echo "        libc interface to Linux kernel ${XBT_LINUX_ARCH} architecture"
echo "        libc interface to Linux kernel ${XBT_LINUX_VER}"
echo "=> for ${TTYLINUX_RAMDISK_SIZE} MB target file system image size"

return 0

}


# *****************************************************************************
# Mount the target filesystem.
# *****************************************************************************

ttylinux_target_mount() {

if [[ -n "$(mount | grep \"${TTYLINUX_IMG_NAME}\")" ]]; then
        echo "E> Already mounted." >&2
        echo "E> ${TTYLINUX_IMG_NAME}" >&2
        return 0
fi

set +e
echo -n "Mounting ..... "
mount -t ext2 -o loop ${TTYLINUX_IMG_NAME} ${TTYLINUX_MNT_DIR}
[[ $? -eq 0 ]] && echo "OK" || echo "FAILED"
set -e

return 0

}


# *****************************************************************************
# Unmount the target filesystem.
# *****************************************************************************

ttylinux_target_umount() {

set +e
echo -n "Unmounting ... "
umount -d ${TTYLINUX_MNT_DIR} 2>/dev/null
[[ $? -eq 0 ]] && echo "OK" || echo "FAILED"
set -e

return 0

}


# *****************************************************************************
# Make a comment.
# *****************************************************************************

ttylinux_build_comment() {

echo "#; $1"

}


# *****************************************************************************
# Make a comment; then execute it.
# *****************************************************************************

ttylinux_build_command() {

echo "#+ $1"
eval $1

}


# *****************************************************************************
# Get the ttylinux kernel source and config file.
# *****************************************************************************

ttylinux_kernel_get() {

local kver="${TTYLINUX_USER_KERNEL:-${XBT_LINUX_VER##*-}}"
local srcd="${TTYLINUX_KERNEL_SRCDIR}"
local kcfg="${TTYLINUX_KERNEL_CONFIG}"

ttylinux_build_comment ""
ttylinux_build_comment "kernel source"
ttylinux_build_comment "=> ${srcd}/linux-${kver}.tar.bz2"

# Look for the linux kernel tarball.
#
if [[ ! -f "${srcd}/linux-${kver}.tar.bz2" ]]; then
	echo "E> Linux kernel source tarball not found." >&2
	echo "=> ${srcd}/linux-${kver}.tar.bz2" >&2
	exit 1
fi

ttylinux_build_comment ""
ttylinux_build_comment "kernel config"
ttylinux_build_comment "=> ${kcfg}"

# Look for the linux kernel configuration file.
#
if [[ ! -f "${kcfg}" ]]; then
	echo "E> Linux kernel configuration file not found." >&2
	echo "=> ${kcfg}" >&2
	exit 1
fi

# Cleanup any previous left-over build results.
#
rm --force --recursive linux-${kver}*/
rm --force --recursive linux/

# Uncompress, untarr then remove linux-${kver}.tar.bz2 and put the kernel
# configuration file in place.
#
ttylinux_build_comment ""
ttylinux_build_command "cp ${srcd}/linux-${kver}.tar.bz2 linux-${kver}.tar.bz2"
ttylinux_build_command "bunzip2 --force linux-${kver}.tar.bz2"
ttylinux_build_command "tar --extract --file=linux-${kver}.tar"
ttylinux_build_command "rm --force linux-${kver}.tar"
ttylinux_build_command "cp ${kcfg} linux-${kver}/.config"

}


# *****************************************************************************
# Add any add-ins and patches.
# *****************************************************************************

ttylinux_kernel_addin_and_patch() {

local kver="${TTYLINUX_USER_KERNEL:-${XBT_LINUX_VER##*-}}"

# Do nothing herein for custom kernels.
#
if [[ -n "${TTYLINUX_USER_KERNEL:-}" ]]; then
	return 0
fi

cd "linux-${kver}"

# This is for older kernels; it is harmless otherwise.
#
if [[ -f scripts/unifdef.c ]]; then
	_cmd="sed -e \"s/getline/uc_&/\" -i scripts/unifdef.c"
	ttylinux_build_comment ""
	ttylinux_build_command "${_cmd}"
	unset _cmd
fi

# This is for older kernels; it is harmless otherwise.
#
if [[ -f scripts/mod/sumversion.c ]]; then
	_old="<string.h>"
	_new="<limits.h>\n#include <string.h>"
	_cmd="sed -e \"s|${_old}|${_new}|\" -i scripts/mod/sumversion.c"
	ttylinux_build_comment ""
	ttylinux_build_command "${_cmd}"
	unset _old
	unset _new
	unset _cmd
fi

# Add-in
#
_tarFile="${TTYLINUX_PLATFORM_DIR}/kernel-${TTYLINUX_CONFIG}-add_in.tar.bz2"
if [[ -f ${_tarFile} ]]; then
	_cmd="tar --extract --file=${_tarFile}"
	ttylinux_build_comment ""
	ttylinux_build_comment "Adding kernel-${TTYLINUX_CONFIG}-add_in.tar.bz2"
	ttylinux_build_command "${_cmd}"
	unset _cmd
fi
unset _tarFile

# Patches
#
for p in ${TTYLINUX_PLATFORM_DIR}/kernel-${TTYLINUX_CONFIG}-??.patch; do
	if [[ -f "${p}" ]]; then
		_cmd="patch -p1 <${p}"
		ttylinux_build_command "${_cmd}"
		unset _cmd
	fi
done

# This is a test to see if a gcc version 4.6.0 or newer is being used on a
# kernel older than 3.0; this is the case with the current ttylinux mac_g4
# kernel and its xbuildtool gcc.  In this case, a bunch of warnings will kill
# the cross-compile of the kernel, but we know the kernel will actually work;
# so Crazy Hack the kernel Makefile to not make warnings be errors.
#
if [[ "${TTYLINUX_PLATFORM}" = "mac_g4" ]]; then
	(source "${TTYLINUX_XTOOL_DIR}/_xbt_env_set"
	_kerVer=${kver%%.*}
	_gccVer=${XBT_XGCC_VER#gcc-}
	_gccVer=${_gccVer//./}
	if [[ ${_kerVer} -lt 3 && ${_gccVer} -gt 460 ]]; then
		ttylinux_build_comment ""
		ttylinux_build_comment "Doing the whacky fix."
		ttylinux_build_comment ""
		sed -e "s|^KBUILD_AFLAGS_KERNEL|KBUILD_CFLAGS += -Wno-error=unused-but-set-variable\nKBUILD_AFLAGS_KERNEL|" -i Makefile
	else
		echo ""                                 >${CONSOLE_FD}
		echo "********************************" >${CONSOLE_FD}
		echo "ERROR !! ERROR"                   >${CONSOLE_FD}
		echo "********************************" >${CONSOLE_FD}
		echo "Fix the cheap mac_g4 kernel hack" >${CONSOLE_FD}
		echo "in scripts/bld-kernel.sh"         >${CONSOLE_FD}
		echo "********************************" >${CONSOLE_FD}
		echo "ERROR !! ERROR"                   >${CONSOLE_FD}
		echo "********************************" >${CONSOLE_FD}
		echo ""                                 >${CONSOLE_FD}
	fi)
fi

cd ..

}


# *************************************************************************** #
#                                                                             #
# _ f u n c t i o n s   B o d y                                               #
#                                                                             #
# *************************************************************************** #

TEXT_BRED="\E[1;31m"    # bold+red
TEXT_BGREEN="\E[1;32m"  # bold+green
TEXT_BYELLOW="\E[1;33m" # bold+yellow
TEXT_BBLUE="\E[1;34m"   # bold+blue
TEXT_BPURPLE="\E[1;35m" # bold+purple
TEXT_BCYAN="\E[1;36m"   # bold+cyan
TEXT_BOLD="\E[1;37m"    # bold+white
TEXT_RED="\E[0;31m"     # red
TEXT_GREEN="\E[0;32m"   # green
TEXT_YELLOW="\E[0;33m"  # yellow
TEXT_BLUE="\E[0;34m"    # blue
TEXT_PURPLE="\E[0;35m"  # purple
TEXT_CYAN="\E[0;36m"    # cyan
TEXT_NORM="\E[0;39m"    # normal

K_TB=$'\t'
K_NL=$'\n'
K_SP=$' '

set -e ; # Exit immediately if a command exits with a non-zero status.
set -u ; # Treat unset variables as an error when substituting.

export IFS="${K_SP}${K_TB}${K_NL}"
export LC_ALL=POSIX
export PATH=/bin:/sbin:/usr/bin:/usr/sbin

ncpus=$(grep "^processor" /proc/cpuinfo | wc -l)

umask 022


# end of file
