#! /bin/sh

# Copyright (c) 2022 Slawomir Wojciech Wojtczak (vermaden)
# All rights reserved.
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
# HDD TEMP FROM smartcrl(8) TOOL
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

__usage() {
  local NAME=${0##*/}
  echo "USAGE:"
  echo "  ${NAME} (without any arguments)"
  echo
  echo "  install 'smartmontools' package for disks temperatures:"
  echo "    # pkg install smartmontools"
  echo
  echo "  you need to execute as 'root' to get disks temperatures"
  echo "    # ${NAME}"
  echo "    % doas ${NAME}"
  echo "    $ sudo ${NAME}"
  echo
  exit 1
}

if [ "${1}" = "-h"    -o \
     "${1}" = "help"  -o \
     "${1}" = "-help" -o \
     "${1}" = "--help" ]
then
  __usage
fi

if [ $( whoami ) != "root" ]
then
  __usage
fi

if ! which smartctl 1> /dev/null 2> /dev/null
then
  exit 0
fi

for I in $( sysctl -n kern.disks | tr ' ' '\n' | sort -n )
do
  case ${I} in
    (cd*)
      continue
      ;;
    (nvd*)
      I=$( echo ${I} | sed -e 's/nvd/nvme/g' )
      smartctl -a /dev/${I} \
        | grep -e Temperature: \
        | sed -E 's|\(.*\)||g' \
        | awk -v DISK=${I} \
            '{MIB="smart." DISK "." tolower($1) ":"; printf("%38s %s.0C\n", MIB, $(NF-1))}'
      ;;
    (*)
      smartctl -a /dev/${I} \
        | grep -e Temperature_ \
        | sed -E 's|\(.*\)||g' \
        | awk -v DISK=${I} \
            '{MIB="smart." DISK "." tolower($2) ":"; printf("%38s %s.0C\n", MIB, $NF)}'
      ;;
  esac
done

echo '1' 2> /dev/null >> ~/scripts/stats/${0##*/}

