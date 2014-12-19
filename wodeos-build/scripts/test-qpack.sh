#!/bin/bash


# This file is part of the ttylinux software.
# The license which this software falls under is GPLv2 as follows:
#
# Copyright (C) 2011-2012 Douglas Jerome <douglas@ttylinux.org>
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
#	This script checks that each file listed in each package list is found
#	in the sysroot.  Also, empty package lists are reported.  The package
#	lists are in sysroot/usr/share/ttylinux.
#
# CHANGE LOG
#
#	19apr13	drj	File creation.
#
# *****************************************************************************


# *************************************************************************** #
#                                                                             #
# S U B R O U T I N E S                                                       #
#                                                                             #
# *************************************************************************** #


# *****************************************************************************
#
# *****************************************************************************

# none


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


# *****************************************************************************
# Main Program
# *****************************************************************************

ht=0
sz=0
f=""
p=""

for p in $(ls sysroot/usr/share/ttylinux/*-FILES); do
	ht=0
	sz=$(stat -c %s ${p})
	if [[ ${sz} == 0 ]]; then
		echo "=> *EMPTY* ${p}"
	fi
	for f in $(<${p}); do
		[[ "${f%%/*}"/ == "dev"/ ]] && continue # skip dev/*
		if [[ ! -f "sysroot/${f}" && ! -d "sysroot/${f}" ]]; then
			if [[ ${ht} == 0 ]]; then
				echo "=> ${p}"
				ht=1
			fi
			echo "-> Missing file \"${f}\""
		fi
	done
done

unset ht
unset sz
unset f
unset p


# *****************************************************************************
# Exit OK
# *****************************************************************************

exit 0


# end of file
