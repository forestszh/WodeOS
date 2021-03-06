#!/bin/bash -eu


# *****************************************************************************
# Check the arguments.
# *****************************************************************************

[[ $# != 1 ]] && {
echo "This script take one argument, top-level ttylinux CD-ROM ISO directory."
echo "Usage: qemu-i686.sh <directory>"
exit 1
}

[[ ! -d $1 ]] && {
echo "\"$1\" is not a directory."
echo "Usage: qemu-i686.sh <directory>"
exit 1
}


# *****************************************************************************
# Look for the qemu executable in the path.
# *****************************************************************************

_path=""
for p in ${PATH//:/ }; do
	if [[ -x $p/qemu-system-i386 ]]; then _path=$p/qemu-system-i386; fi
done
if [[ x"${_path}" = x ]]; then
	echo ""
	echo "Cannot find an executable \"qemu-system-i386\" program"
	echo "in your \$PATH setting.  Maybe you need to set your \$PATH"
	echo "or download and install qemu."
	echo "Qemu can be found at http://wiki.qemu.org/"
	echo ""
	exit 1
fi
unset _path


# *****************************************************************************
# Run qemu with the kernel and file system.
# *****************************************************************************

echo -e "\e[1;31m"
cat - <<EOF
.---..---..-..-..-.   .-..-..-..-..-..-..-.
\`| |'\`| |' >  / | |__ | || .\` || || | >  < 
 \`-'  \`-'  \`-'  \`----'\`-'\`-'\`-'\`----''-'\`-\`
EOF
echo ""
echo -e "\e[1;34mWodeOS\e[0;39m is distributed with ABSOLUTELY NO WARRANTY."
echo -e "\e[1;36mhttp://www.360diy.org\e[0;39m"
echo ""
echo -e "\e[34mWodeOS boot options:\e[0;39m"
echo ""
echo -e " console=<tty*>\e[34m ............ Use serial port ttyS* for console and login.\e[0;39m"
echo -e "                             \e[34mFor \e[0;39m<tty*>\e[34m use one of \e[0;39mttyS0\e[34m, \e[0;39mttyS1\e[34m, \e[0;39mttyS2\e[34m, \e[0;39mttyS3\e[0;39m"
echo ""
echo -e " login=<tty*,tty*,...>\e[34m ..... Allow login on devices e.g., \e[0;39mttyS1\e[34m, etc.\e[0;39m"
echo -e " nologin=<tty*,tty*,...>\e[34m ... Disallow login on devices e.g., \e[0;39mtty1\e[34m, \e[0;39mtty2\e[34m, etc.\e[0;39m"
echo -e " modules=<module,...>\e[34m ...... Load specific kernel module(s) named \e[0;39m<module>\e[34m.\e[0;39m"
echo -e " enet\e[34m ...................... Startup Ethernet networking.\e[0;39m"
echo -e " nofirewall\e[34m ................ Do not startup the firewall.\e[0;39m\e[0;39m"
echo -e " nofsck\e[34m .................... Do not check the file systems.\e[0;39m\e[0;39m"
echo -e " nosshd\e[34m .................... Do not start sshd, the Secure Shell server.\e[0;39m"
echo -e " host=<name.domain.tld>\e[34m .... Set the hostname to \e[0;39m<name.domain.tld>\e[0;34m.\e[0;39m"
echo -e " hwclock=(local|utc)\e[34m ....... CMOS clock keeps \e[0;39mlocal\e[34m or \e[0;39mUTC\e[34m time.\e[0;39m"
echo -e " tz=<timezone>\e[34m ............. Set timezone to \e[0;39m<timezone>."
echo ""
echo -e "\e[34mPress \e[0;39m<Enter>\e[0;34m to begin or type space-separated boot options and then \e[0;39m<Enter>\e[0;39m"

echo ""
read -p "ttylinux: "


# *****************************************************************************
# Run qemu with the kernel and file system.
# *****************************************************************************

_initrd=boot/filesys.gz
_kernel=boot/vmlinuz
_rdsksz="ramdisk_size=65536"

qemu-system-i386					\
	-enable-kvm					\
	-cpu coreduo					\
	-smp 2,maxcpus=2,cores=2,threads=2,sockets=2	\
	-m 192						\
	-net nic,model=virtio				\
	-kernel $1/${_kernel}				\
	-initrd $1/${_initrd}				\
	-append "initrd=/${_initrd} root=/dev/ram0 ${_rdsksz} ro ${REPLY}"

unset _initrd
unset _kernel
unset _rdsksz


# *****************************************************************************
# Exit OK
# *****************************************************************************

exit 0
