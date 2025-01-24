#! /bin/sh

# Copyright (c) 2024 Slawomir Wojciech Wojtczak (vermaden)
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
# SIMPLE BHYVE(8) VNC CONNECTION
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

__usage() {
  NAME=${0##*/}
  cat << HELP
usage:
  ${NAME} -l
  ${NAME} <VM>

example(s):
  # ${NAME} -l
  # ${NAME} freebsd-14.1
  # ${NAME} netbsd-test-vm

HELP
  exit 1
}

[ ${#} -ne 1 ] && __usage

unalias vncviewer    1> /dev/null 2> /dev/null
if ! which vncviewer 1> /dev/null 2> /dev/null
then
  echo "NOPE: install 'net/tigervnc-viewer' package"
  exit 1
fi

unalias vm    1> /dev/null 2> /dev/null
if ! which vm 1> /dev/null 2> /dev/null
then
  echo "NOPE: install 'sysutils/vm-bhyve-devel' package"
fi

VM_LIST=$( doas vm list 2> /dev/null || sudo vm list 2> /dev/null )

case ${1} in
  (-l)
    echo "${VM_LIST}" \
      | while read NAME DATASTORE LOADER CPU MEMORY VNC AUTO STATE GARBAGE
        do
          if [ "${VNC}" != "-" ]
          then
            echo "${NAME} ${VNC}"
          fi
        done | column -t
    exit 0
    ;;
  (-h|--help|-help|help)
    __usage
    ;;
esac

VM=$( echo "${VM_LIST}" | grep -m 1 "^${1} " | awk '{print $1}' )
if [ "${VM}" = "" ]
then
  echo "NOPE: virtual machine '${1}' does not exist"
  exit 1
fi

while read NAME DATASTORE LOADER CPU MEMORY VNC AUTO STATE GARBAGE
do
  case ${STATE} in
    (Running.*|Locked.*)
      # THE 'Locked' STATE IS USED WHEN 'vm install ...' COMMAND IS USED
      echo "NOPE: virtual machine '${1}' is stopped"
      exit 1
      ;;
  esac
done << ECHO
  $( echo "${VM_LIST}" | grep -m 1 "^${1} " )
ECHO

VNC=$( echo "${VM_LIST}" | grep -m 1 "^${1} " | awk '{print $6}' )
if [ "${VNC}" = "-" ]
then
  echo "NOPE: virtual machine '${1}' does not listen on VNC port"
  exit 1
fi

unset VM_LIST STATE VM
vncviewer ${VNC} 1> /dev/null 2> /dev/null &

# NOTES
# vm list | awk '{a=NF; print $a; b=a-1; print $b}'

