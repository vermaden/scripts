#! /bin/sh

# Copyright (c) 2018 Slawomir Wojciech Wojtczak (vermaden)
# All rights reserved.
#
# THIS SOFTWARE USES FREEBSD LICENSE (ALSO KNOWN AS 2-CLAUSE BSD LICENSE)
# https://www.freebsd.org/copyright/freebsd-license.html
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that following conditions are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS 'AS IS' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# ------------------------------
# openbox(1) WITH cpufreq(4)
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

SUDO_WHICH=0
SUDO=0
DOAS_WHICH=0
DOAS=1
ROOT=0

# CHECK doas(8) WITH which(1)
if which doas 1> /dev/null 2> /dev/null
then
  DOAS_WHICH=1
else
  DOAS_WHICH=0
fi

# CHECK sudo(8) WITH which(1)
if which sudo 1> /dev/null 2> /dev/null
then
  SUDO_WHICH=1
else
  SUDO_WHICH=0
fi

# CHECK USER WITH whoami(1)
if [ "$( whoami )" = "root" ]
then
  ROOT=1
fi

# CHOOSE ONE FROM doas(8) AND sudo(8)
if [ ${DOAS_WHICH} -eq 1 -o ${SUDO_WHICH} -eq 1 ]
then
  if [   ${DOAS} -eq 0 -a ${SUDO} -eq 1 -a ${SUDO_WHICH} -eq 1 ]
  then
    CMD=sudo
  elif [ ${DOAS} -eq 1 -a ${SUDO} -eq 0 -a ${DOAS_WHICH} -eq 1 ]
  then
    CMD=doas
  elif [ ${DOAS} -eq 1 -a ${SUDO} -eq 1 -a ${DOAS_WHICH} -eq 1 ]
  then
    CMD=doas
  fi
elif [ ${ROOT} -eq 1 ]
then
  CMD=''
else
  echo "NOPE: This script needs 'doas' or 'sudo' to work properly."
  exit 1
fi

unset SUDO_WHICH
unset DOAS_WHICH
unset ROOT

__usage() {
  echo "usage: ${0##*/} MIN MAX"
  echo
  exit 1
}

# FreeBSD 6.0 - 8.1
# sysctl debug.cpufreq.highest=${1}

# FreeBSD 8.2 - CURRENT
case ${#} in
  (2)
    [ ${1} -gt ${2} ] && __usage
    if [ "${1}" = "0" -a "${2}" = "0" ]
    then
      ${CMD} /usr/local/etc/rc.d/powerdxx onestop
      ${CMD} /etc/rc.d/powerd             onestop
      ${CMD} killall -9 powerd++ powerd
      ${CMD} sysctl dev.cpu.0.freq=800
    else
      FLAGS="-n adaptive -a hiadaptive -b adaptive -m ${1} -M ${2}"
      POWERDXX_FLAGS="powerdxx_flags=\"${FLAGS}\""
      POWERD_FLAGS="powerd_flags=\"${FLAGS}\""
      ${CMD} sed -i -E s/"powerd_flags.*$"/"${POWERD_FLAGS}"/g     /etc/rc.conf
      ${CMD} sed -i -E s/"powerdxx_flags.*$"/"${POWERDXX_FLAGS}"/g /etc/rc.conf
      ${CMD} /etc/rc.d/powerd             restart
      ${CMD} /usr/local/etc/rc.d/powerdxx restart
    fi
    ;;

  (*)
    __usage
    ;;

esac
