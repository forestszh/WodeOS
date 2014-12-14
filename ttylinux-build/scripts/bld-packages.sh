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
#	This script builds the ttylinux packages.
#
# CHANGE LOG
#
#	08may13	drj	Added more possibilities for the 'pkg-cfg/files' file.
#	30apr13	drj	Changed some error handling.
#	30apr13	drj	Put the source package unzip back into this file.
#	25apr13	drj	Handle odd zipfile names: unzip in the bld.sh files.
#	14apr12	drj	Make an error if a package list file is not found.
#	26mar12	drj	Added support for xz decompressin of source tarballs.
#	16mar12	drj	Changed the package done flags' location.
#	16mar12	drj	Even better setting NJOBS.
#	08mar12	drj	Better setting NJOBS.
#	16feb12	drj	Rewrite for build process reorganization.
#	22jan12	drj	Minor fussing.
#	23jan11	drj	Minor fussing.
#	16jan11	drj	Added possible TTYLINUX_CPU-specific file list.
#	14jan11	drj	Changed the exe and lib stripping process.
#	13jan11	drj	Added check and show for left-over stuff in BUILD.
#	10jan11	drj	Changed for merging pkg-bld into pkg-cfg.
#	09jan11	drj	Changed pkg_clean to be called after package collection.
#	03jan11	drj	Fixed file stripping.
#	16nov10	drj	Miscellaneous fussing.
#	09oct10	drj	Minor simplifications.
#	02apr10	drj	Unhandle glibc-* and added _files filter.
#	04mar10	drj	Removed ttylinux.site-config.sh and handle glibc-*.
#	23jul09	drj	Switched to bash, simplified output and fixed $NJOBS.
#	07oct08	drj	File creation.
#
# *****************************************************************************


# *************************************************************************** #
#                                                                             #
# S U B R O U T I N E S                                                       #
#                                                                             #
# *************************************************************************** #


# *****************************************************************************
# Get and untar a source package.
# *****************************************************************************

package_get() {

# Function Arguments:
# $1 ... Source package zip-file name, like "lynx2.8.7.tar.bz2".

local srcPkg="$1"
local tarBall=""
local unZipper=""

if   [[ "$1" =~ (.*)\.tgz$      ]]; then unZipper="gunzip --force";
elif [[ "$1" =~ (.*)\.tar\.gz$  ]]; then unZipper="gunzip --force";
elif [[ "$1" =~ (.*)\.tbz$      ]]; then unZipper="bunzip2 --force";
elif [[ "$1" =~ (.*)\.tar\.bz2$ ]]; then unZipper="bunzip2 --force";
elif [[ "$1" =~ (.*)\.tar\.xz$  ]]; then unZipper="xz --decompress --force";
fi

if [[ -n "${unZipper}" ]]; then
	tarBall="${BASH_REMATCH[1]}.tar"
	cp "${TTYLINUX_PKGSRC_DIR}/${srcPkg}" .
	${unZipper} "${srcPkg}" >/dev/null
	tar --extract --file="${tarBall}"
	rm --force "${tarBall}"
else
	echo "ERROR ***** ${srcPkg} not recognized." # Make a log file entry.
	echo -e "${TEXT_BRED}ERROR${TEXT_NORM}"         >&${CONSOLE_FD}
	echo    "E> Source package ${srcPkg} not found" >&${CONSOLE_FD}
	exit 1 # Bust out of sub-shell.
fi

}


# *****************************************************************************
# Make a file to list the ttylinux package contents.
# *****************************************************************************

package_list_make() {

# The file cfg-$1/files is an ASCII file that is the list of files from which
# to make the binary package.  cfg-$1/files can have some scripting that
# interprets build script variables to enable the selection of package files
# based upon the shell variables' values, so cfg-$1/files takes some special
# processing.  It is filtered, honoring any ebedded shell scripting, and the
# actual list of binary package files is created as ${TTYLINUX_VAR_DIR}/files

local cfgPkgFiles="$1"

local retStat=0
local lineNum=0
local nLineUse=1
local oLineUse=1
local nesting=0

echo "##### Making Package File List"

rm --force "${TTYLINUX_VAR_DIR}/files"
>"${TTYLINUX_VAR_DIR}/files"
while read; do
	lineNum=$((${lineNum}+1))
	grep -q "^#if" <<<${REPLY} && {
		if [[ ${nesting} == 1 ]]; then
			echo "E> Cannot nest scripting in cfg-$1/files"
			echo "=> line ${lineNum}: \"${REPLY}\""
			continue
		fi
		set ${REPLY}
		if [[ $# != 4 ]]; then
			echo "E> IGNORING malformed script in cfg-$1/files"
			echo "=> line ${lineNum}: \"${REPLY}\""
			continue
		fi
		oLineUse=${nLineUse}
		eval [[ "\$$2" $3 "$4" ]] && nLineUse=1 || nLineUse=0
		nesting=1
	}
	grep -q "^#endif" <<<${REPLY} && { # Manage the #endif lines.  These
		nLineUse=${oLineUse}       # must start in the first column.
		nesting=0
	}
	grep -q "^ *#" <<<${REPLY} && echo "Skipping ${REPLY}"
	grep -q "^ *#" <<<${REPLY} && continue # Manage the comment lines.
	[[ ${nLineUse} == 1 ]] && echo ${REPLY} >>"${TTYLINUX_VAR_DIR}/files"
done <"${cfgPkgFiles}"

while read; do
	if [[ ! -e ${TTYLINUX_SYSROOT_DIR}/${REPLY} ]]; then
		echo "ERROR ***** missing \"${REPLY}\"" # Make a log file entry.
		echo "=> in ${cfgPkgFiles}"             # Make a log file entry.
		retStat=1
	fi
done <"${TTYLINUX_VAR_DIR}/files"

if [[ ${retStat} -eq 1 ]]; then
	echo -e "${TEXT_BRED}ERROR${TEXT_NORM}"          >&${CONSOLE_FD}
	echo    "E> Cannot interpret ${cfgPkgFiles}."    >&${CONSOLE_FD}
fi

return ${retStat}

}


# *****************************************************************************
# Build a package from source and make a binary package.
# *****************************************************************************

package_xbuild() {

# Function Arguments:
#      $1 ... Package name, like "glibc-2.19".

# Check for the package build script.
#
if [[ ! -f "${TTYLINUX_PKGCFG_DIR}/$1/bld.sh" ]]; then
	echo "ERROR ***** Cannot find build script." # Make a log file entry.
	echo "=> ${TTYLINUX_PKGCFG_DIR}/$1/bld.sh"   # Make a log file entry.
	echo -e "${TEXT_BRED}ERROR${TEXT_NORM}"          >&${CONSOLE_FD}
	echo    "E> Cannot find build script."           >&${CONSOLE_FD}
	echo    "   => ${TTYLINUX_PKGCFG_DIR}/$1/bld.sh" >&${CONSOLE_FD}
	exit 1 # Bust out of sub-shell.

fi

# ${TTYLINUX_PKGCFG_DIR}/$1/bld.sh defines several variables and functions:
#
# Functions
#
#	pkg_patch	This function applies any patches or fixups to the
#			source package before building.
#			NOTE -- Patches are applied before package
#				configuration.
#
#	pkg_configure	This function configures the source package for
#			building.
#			NOTE -- Post-configuration patches might be applied.
#
#	pkg_make	This function builds the source package in place in the
#			${TTYLINUX_BUILD_DIR}/packages/ directory
#
#	pkg_install	This function installs any built items into the build
#			root ${TTYLINUX_SYSROOT_DIR}/ directory tree.
#
#	pkg_clean	This function is responsible for cleaning-up; notice
#			it is not called if one of the other functions
#			returns an error.
#
# Variables
#
#	PKG_ZIP		The name of the source package tar-zip file.
#
#	PKG_TAR		The name of the unzipped source package file.  This
#			file name will end in ".tar".
#
#	PKG_DIR		The name of the directory created by untarring the
#			${PKG_TAR} file.
#
#	PKG_STATUS	Set by the above function to indicate an error worthy
#			stopping the build process.
#
source "${TTYLINUX_PKGCFG_DIR}/$1/bld.sh"

echo -n "g." >&${CONSOLE_FD}

# Get the source package, if any.  This function will unzip and untar the
# soucre package.
#
[[ "x${PKG_ZIP}" == "x(none)" ]] || package_get ${PKG_ZIP}

# Get the ttylinux-specific rootfs, if any.
#
if [[ -f "${TTYLINUX_PKGCFG_DIR}/$1/rootfs.tar.bz2" ]]; then
	cp "${TTYLINUX_PKGCFG_DIR}/$1/rootfs.tar.bz2" .
	bunzip2 --force "rootfs.tar.bz2"
	tar --extract --file="rootfs.tar"
	rm --force "rootfs.tar"
fi

# Prepare to create a list of the installed files.
#
rm --force INSTALL_STAMP
rm --force FILES
>INSTALL_STAMP
>FILES
sleep 1 # For detecting files newer than INSTALL_STAMP

# Patch, configure, build, install and clean.
#
PKG_STATUS=""
bitch=${ncpus:-1}
[[ -z "${bitch//[0-9]}" ]] && NJOBS=$((${bitch:-1} + 1)) || NJOBS=2
unset bitch
echo -n "b." >&${CONSOLE_FD}
[[ -z "${PKG_STATUS}" ]] && pkg_patch     $1
[[ -z "${PKG_STATUS}" ]] && pkg_configure $1
[[ -z "${PKG_STATUS}" ]] && pkg_make      $1
[[ -z "${PKG_STATUS}" ]] && pkg_install   $1
[[ -z "${PKG_STATUS}" ]] && pkg_clean     $1
unset NJOBS
if [[ -n "${PKG_STATUS}" ]]; then
	echo "ERROR ***** ${PKG_STATUS}" # Make a log file entry.
	echo -e "${TEXT_BRED}ERROR${TEXT_NORM}" >&${CONSOLE_FD}
	echo    "E> ${PKG_STATUS}"              >&${CONSOLE_FD}
	rm --force INSTALL_STAMP
	rm --force FILES
	exit 1 # Bust out of sub-shell.
fi
unset PKG_STATUS

# Only the latest revision of libtool understands sysroot, but even it has
# problems when cross-building: remove the .la files.
#
rm --force ${TTYLINUX_SYSROOT_DIR}/lib/*.la
rm --force ${TTYLINUX_SYSROOT_DIR}/usr/lib/*.la

# Remove the un-tarred source package directory, the un-tarred rootfs directory
# and any other needed un-tarred source package directories.
#
[[ -d "${PKG_DIR}" ]] && rm --force --recursive "${PKG_DIR}" || true
[[ -d "rootfs"     ]] && rm --force --recursive "rootfs"     || true

# Make a list of the installed files.  Remove sysroot and its path component
# from the file names.
#
echo -n "f." >&${CONSOLE_FD}
find ${TTYLINUX_SYSROOT_DIR} -newer INSTALL_STAMP | sort >> FILES
sed --in-place "FILES" --expression="\#^${TTYLINUX_SYSROOT_DIR}\$#d"
sed --in-place "FILES" --expression="s|^${TTYLINUX_SYSROOT_DIR}/||"
rm --force INSTALL_STAMP # All done with the INSTALL_STAMP file.

# Strip when possible.
#
XBT_STRIP="${TTYLINUX_XTOOL_DIR}/host/usr/bin/${TTYLINUX_XBT}-strip"
_bname=""
if [[ x"${TTYLINUX_STRIP_BINS:-}" == x"y" ]]; then
	echo "***** stripping"
	for f in $(<FILES); do
		[[ -d "${TTYLINUX_SYSROOT_DIR}/${f}" ]] && continue || true
		if [[ "$(dirname ${f})" == "bin" ]]; then
			echo "stripping ${f}"
			"${XBT_STRIP}" "${TTYLINUX_SYSROOT_DIR}/${f}" || true
		fi
		if [[ "$(dirname ${f})" == "sbin" ]]; then
			echo "stripping ${f}"
			"${XBT_STRIP}" "${TTYLINUX_SYSROOT_DIR}/${f}" || true
		fi
		if [[ "$(dirname ${f})" == "usr/bin" ]]; then
			echo "stripping ${f}"
			"${XBT_STRIP}" "${TTYLINUX_SYSROOT_DIR}/${f}" || true
		fi
		if [[ "$(dirname ${f})" == "usr/sbin" ]]; then
			echo "stripping ${f}"
			"${XBT_STRIP}" "${TTYLINUX_SYSROOT_DIR}/${f}" || true
		fi
_bname="$(basename ${f})"
[[ $(expr "${_bname}" : ".*\\(.o\)$" ) == ".o" ]] && continue || true
[[ $(expr "${_bname}" : ".*\\(.a\)$" ) == ".a" ]] && continue || true
		if [[ "$(dirname ${f})" == "lib" ]]; then
			echo "stripping ${f}"
			"${XBT_STRIP}" "${TTYLINUX_SYSROOT_DIR}/${f}" || true
		fi
[[ "${_bname}" == "libgcc_s.so"   ]] && continue || true
[[ "${_bname}" == "libgcc_s.so.1" ]] && continue || true
		if [[ "$(dirname ${f})" == "usr/lib" ]]; then
			echo "stripping ${f}"
			"${XBT_STRIP}" "${TTYLINUX_SYSROOT_DIR}/${f}" || true
		fi
	done
else
	echo "***** not stripping"
fi
unset _bname

return 0

}


# *****************************************************************************
# Find the installed man pages, compress them, and adjust the file name in the
# so called database FILES list.
# *****************************************************************************

manpage_compress() {

local i=0
local f=""
#local lFile=""  # link file
#local mFile=""  # man file
#local manDir="" # man file directory

[[ -n "${BUILD_MASK}" ]] && return 0 || true

echo -n "m" >&${CONSOLE_FD}
for f in $(<FILES); do
	[[ -d "${TTYLINUX_SYSROOT_DIR}/${f}" ]] && continue || true
	if [[ -n "$(grep "^usr/share/man/man" <<<${f})" ]]; then
		i=$(($i + 1))
#
# The goal of this is to gzip any non-gziped man pages.  The problem is that
# some of those have more than one sym link to them; how to fixup all the
# symlinks?
#
#		lFile=""
#		mFile=$(basename ${f})
#		manDir=$(dirname ${f})
#		pushd "${TTYLINUX_SYSROOT_DIR}/${manDir}" >/dev/null 2>&1
#		if [[ -L ${mFile} ]]; then
#			lFile="${mFile}"
#			mFile="$(readlink ${lFile})"
#		fi
#		if [[	x"${mFile%.gz}"  == x"${mFile}" && \
#			x"${mFile%.bz2}" == x"${mFile}" ]]; then
#			echo "zipping \"${mFile}\""
#			gzip "${mFile}"
#			if [[ -n "${lFile}" ]]; then
#				rm --force "${lFile}"
#				ln --force --symbolic "${mFile}.gz" "${lFile}"
#			fi
#			sed --in-place "${TTYLINUX_BUILD_DIR}/packages/FILES" \
#				--expression="s|${mFile}$|${mFile}.gz|"
#		fi
#		popd >/dev/null 2>&1
	fi
done
[[ ${#i} -eq 1 ]] && echo -n "___${i}." >&${CONSOLE_FD}
[[ ${#i} -eq 2 ]] && echo -n  "__${i}." >&${CONSOLE_FD}
[[ ${#i} -eq 3 ]] && echo -n   "_${i}." >&${CONSOLE_FD}
[[ ${#i} -eq 4 ]] && echo -n    "${i}." >&${CONSOLE_FD}

return 0

}


# *****************************************************************************
# Collect the installed files into an as-built packge.
# *****************************************************************************

package_collect() {

local fileList=""

[[ -n "${BUILD_MASK}" ]] && return 0 || true

# Make the binary package: make a tarball of the files that is specified in the
# package configuration; this is found in "${TTYLINUX_PKGCFG_DIR}/$1/files".

# Save the list of files actually installed into sysroot/
#
cp --force FILES "${TTYLINUX_SYSROOT_DIR}/usr/share/ttylinux/pkg-$1-FILES"
rm --force FILES # All done with the FILES file.

# Look for a package configuration file list.  There does not need to be one.
#
_fname="${TTYLINUX_PKGCFG_DIR}/$1/files"
if [[ -f "${_fname}" ]]; then
	fileList="${_fname}"
fi
if [[ -f "${_fname}-${TTYLINUX_PLATFORM}" ]]; then
	fileList="${_fname}-${TTYLINUX_PLATFORM}"
fi
if [[ -f "${_fname}-${TTYLINUX_PLATFORM}-${TTYLINUX_CONFIG}" ]]; then
	fileList="${_fname}-${TTYLINUX_PLATFORM}-${TTYLINUX_CONFIG}"
fi

# Remark on the current activity.  Probably do something interesting.
#
if [[ -n "${fileList}" ]]; then
	echo -n "p." >&${CONSOLE_FD}
	#
	# This is tricky.  First make "${TTYLINUX_VAR_DIR}/files" from
	# "${fileList}"; then make a binary package from the list in
	# "${TTYLINUX_VAR_DIR}/files".
	#
	package_list_make "${fileList}" || exit 1 # Bust out of sub-shell.
	uTarBall="${TTYLINUX_PKGBIN_DIR}/$1-${TTYLINUX_CPU}.tar"
	cTarBall="${TTYLINUX_PKGBIN_DIR}/$1-${TTYLINUX_CPU}.tbz"
	tar --create \
		--directory="${TTYLINUX_SYSROOT_DIR}" \
		--file="${uTarBall}" \
		--files-from="${TTYLINUX_VAR_DIR}/files" \
		--no-recursion
	bzip2 --force "${uTarBall}"
	mv --force "${uTarBall}.bz2" "${cTarBall}"
	unset uTarBall
	unset cTarBall
	rm --force "${TTYLINUX_VAR_DIR}/files" # Remove the temporary file.
	#
else
	echo -n "XX" >&${CONSOLE_FD}
fi

echo -n "c" >&${CONSOLE_FD}

return 0

}


# *************************************************************************** #
#                                                                             #
# M A I N   P R O G R A M                                                     #
#                                                                             #
# *************************************************************************** #


# *****************************************************************************
# Set up the shell functions and environment variables.
# *****************************************************************************

source ./ttylinux-config.sh    # target build configuration
source ./scripts/_functions.sh # build support

dist_root_check    || exit 1
dist_config_setup  || exit 1
build_config_setup || exit 1
build_spec_show    || exit 1

BUILD_MASK="" # This is a mechanism to skip building a package, as commanded by
              # the package build script.

ZIPP="" # This is a mechanism to skip already-built packages.
if [[ $# -gt 0 ]]; then
	# "$1" may be unbound so hide it in this if statement.
	# Set the ZIPP flag, if so specified; otherwise reset the package list.
	[[ "$1" == "continue" ]] && ZIPP="y" || TTYLINUX_PACKAGE=("$1")
fi

if [[ ! -d "${TTYLINUX_BUILD_DIR}/packages" ]]; then
	echo "E> The build directory does NOT exist."
	echo "E>      ${TTYLINUX_BUILD_DIR}/packages"
	exit 1
fi

if [[ -z "${TTYLINUX_PACKAGE}" ]]; then
	echo "E> No packages to build.  How did you do that?"
	exit 1
fi


# *****************************************************************************
# Main Program
# *****************************************************************************

echo ""
echo "##### START cross-building packages"
echo "g - getting the source and configuration packages"
echo "b - building and installing the package into sysroot"
echo "f - finding installed files"
echo "m - looking for man pages to compress"
echo "p - creating ttylinux-installable package"
echo "c - cleaning"
echo ""

pushd "${TTYLINUX_BUILD_DIR}/packages" >/dev/null 2>&1

if [[ $(ls -1 | wc -l) -ne 0 ]]; then
	echo "w> build/packages build directory is not empty:"
	ls -l
	echo ""
fi

T1P=${SECONDS}

for p in ${TTYLINUX_PACKAGE[@]}; do

	[[ -n "${ZIPP}" && -f "${TTYLINUX_VAR_DIR}/run/done.${p}" ]] && continue

	if [[ ! -d "${TTYLINUX_PKGCFG_DIR}/${p}" ]]; then
		echo -e "E> No ${TEXT_RED}pkg-cfg/${p}${TEXT_NORM} directory."
		exit 1
	fi

	t1=${SECONDS}

	echo -n "${p} ";
	for ((i=(30-${#p}) ; i > 0 ; i--)); do echo -n "."; done
	echo -n " ";

	exec 4>&1    # Save stdout at fd 4.
	CONSOLE_FD=4 #

	set +e ; # Let a build step fail without exiting this script.

	if [[ -d "${TTYLINUX_PKGCFG_DIR}/${p}" ]]; then
		(
		rm --force "${TTYLINUX_VAR_DIR}/log/${p}.log"
		package_xbuild  "${p}" >>"${TTYLINUX_VAR_DIR}/log/${p}.log" 2>&1
		manpage_compress       >>"${TTYLINUX_VAR_DIR}/log/${p}.log" 2>&1
		package_collect "${p}" >>"${TTYLINUX_VAR_DIR}/log/${p}.log" 2>&1
		)
	fi

	if [[ $? -ne 0 ]]; then
		echo "Check the build log files.  Probably check:"
		echo "=> ${TTYLINUX_VAR_DIR}/log/${p}.log"
		exit 1
	fi

	set -e ; # All done with build steps; fail enabled.

	exec >&4     # Set fd 1 back to stdout.
	CONSOLE_FD=1 #

	touch "${TTYLINUX_VAR_DIR}/run/done.${p}"

	echo -n " ... DONE ["
	t2=${SECONDS}
	mins=$(((${t2}-${t1})/60))
	secs=$(((${t2}-${t1})%60))
	[[ ${#mins} -eq 1 ]] && echo -n " "; echo -n "${mins} minutes "
	[[ ${#secs} -eq 1 ]] && echo -n " "; echo -n "${secs} seconds"
	echo "]"

	if [[ $(ls -1 | wc -l) -ne 0 ]]; then
		echo "w> build/packages build directory is not empty:"
		ls -l
	fi

	BUILD_MASK=""

done

T2P=${SECONDS}
echo "=> $(((${T2P}-${T1P})/60)) minutes $(((${T2P}-${T1P})%60)) seconds"
echo ""

popd >/dev/null 2>&1

echo "##### DONE cross-building packages"


# *****************************************************************************
# Exit OK
# *****************************************************************************

exit 0


# end of file
