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
# MOUNT ISO IMAGE FreeBSD/SunOS/Linux
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

[ ${#} -ne 2 ] && {
  echo "usage: ${0##*/} image.iso /mnt/point"
  exit 1
}

__absolute() {
  if [ -f /${1} ]
  then
    echo "${1}"
  else
    echo "$( pwd )/${1}"
  fi
}

mkdir -p "${2}" || {
  echo "ER: can not create mount directory"
  exit 1
  }

case $( uname ) in
  (FreeBSD)
    NODE=$( mdconfig -a -t vnode -f "${1}" )
    mount -t cd9660 /dev/${NODE} "${2}"
    ;;

  (SunOS)
    FILE=$(  __absolute "${1}" )
    POINT=$( __absolute "${2}" )
    lofiadm -d "${FILE}" 1> /dev/null
    NODE=$( lofiadm -a "${FILE}" )
    mount -F hsfs -o ro ${NODE} "${POINT}"
    ;;

  (Linux)
    mount -o loop "${1}" "${2}"
    ;;

  (*)
    echo "supported systems: FreeBSD Solaris Linux"
    exit 1
    ;;
esac

# OpenBSD
# vnconfig svnd0 image.iso
# mount -t cd9660 /dev/svnd0c /mnt
