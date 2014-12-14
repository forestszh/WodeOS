# vim: syntax=sh

# For each index i, _GCC[i] _CLOOG[i] _GMP[i] _MPC[i] _MPFR[i] _PPL[i] all are
# a matched set; which means these are a matched set:
#      _GCC[0]  _CLOOG[0]  _GMP[0]  _MPC[0]  _MPFR[0]  _PPL[0]
#      _GCC[1]  _CLOOG[1]  _GMP[1]  _MPC[1]  _MPFR[1]  _PPL[1]
# and so on.

# *****************************************************************************
# CLOOG
# *****************************************************************************

_CLOOG[0]=""             ; _CLOOG_EXT[0]=""
_CLOOG[1]="cloog-0.16.1" ; _CLOOG_EXT[1]=".tar.gz"

_CLOOG_MD5SUM[0]=""
_CLOOG_MD5SUM[1]="947123350d1ff6dcb4b0774947ac015a"

_CLOOG_URL[0]=""
_CLOOG_URL[1]="ftp://gcc.gnu.org/pub/gcc/infrastructure/"

# *****************************************************************************
# GMP
# *****************************************************************************

_GMP[0]="gmp-4.3.2" ; _GMP_EXT[0]=".tar.bz2"
_GMP[1]="gmp-5.0.5" ; _GMP_EXT[1]=".tar.bz2"

_GMP_MD5SUM[0]="dd60683d7057917e34630b4a787932e8"
_GMP_MD5SUM[1]="041487d25e9c230b0c42b106361055fe"

_GMP_URL[0]="http://ftp.sunet.se/pub/gnu/gmp http://ftp.gnu.org/gnu/gmp/"
_GMP_URL[1]="http://ftp.sunet.se/pub/gnu/gmp http://ftp.gnu.org/gnu/gmp/"

# *****************************************************************************
# MPC
# *****************************************************************************

_MPC[0]=""          ; _MPC_EXT[0]=""
_MPC[1]="mpc-1.0.1" ; _MPC_EXT[1]=".tar.gz"

_MPC_MD5SUM[0]=""
_MPC_MD5SUM[1]="b32a2e1a3daa392372fbd586d1ed3679"

_MPC_URL[0]=""
_MPC_URL[1]="http://www.multiprecision.org/mpc/download/"

# *****************************************************************************
# MPFR
# *****************************************************************************

_MPFR[0]="mpfr-2.4.2" ; _MPFR_EXT[0]=".tar.bz2"
_MPFR[1]="mpfr-3.1.1" ; _MPFR_EXT[1]=".tar.bz2"

_MPFR_MD5SUM[0]="89e59fe665e2b3ad44a6789f40b059a0"
_MPFR_MD5SUM[1]="e90e0075bb1b5f626c6e31aaa9c64e3b"

_MPFR_URL[0]="http://www.mpfr.org/mpfr-2.4.2/"
_MPFR_URL[1]="http://www.mpfr.org/mpfr-3.1.1/"

# *****************************************************************************
# PPL
# *****************************************************************************

_PPL[0]=""         ; _PPL_EXT[0]=""
_PPL[1]="ppl-0.11" ; _PPL_EXT[1]=".tar.gz"

_PPL_MD5SUM[0]=""
_PPL_MD5SUM[1]="ba527ec0ffc830ce16fad8a4195a337e"

_PPL_URL[0]=""
_PPL_URL[1]="ftp://gcc.gnu.org/pub/gcc/infrastructure"

# *****************************************************************************
# GCC
# *****************************************************************************

_GCC[0]="gcc-4.4.6" ; _GCC_EXT[0]=".tar.bz2"
_GCC[1]="gcc-4.6.3" ; _GCC_EXT[1]=".tar.bz2"

_GCC_MD5SUM[0]="ab525d429ee4425050a554bc9247d6c4"
_GCC_MD5SUM[1]="773092fe5194353b02bb0110052a972e"

_GCC_URL[0]="ftp://ftp.gnu.org/gnu/gcc/${_GCC[0]} http://ftp.gnu.org/gnu/gcc/${_GCC[0]} ftp://sourceware.org/pub/gcc/releases/${_GCC[0]}/"
_GCC_URL[1]="ftp://ftp.gnu.org/gnu/gcc/${_GCC[1]} http://ftp.gnu.org/gnu/gcc/${_GCC[1]} ftp://sourceware.org/pub/gcc/releases/${_GCC[1]}/"
