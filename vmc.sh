#! /bin/sh

# Copyright (c) 2023-2024 Slawomir Wojciech Wojtczak (vermaden)
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
# BHYVE(8) VMs PAUSE/RESUME TOOL
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

# COLORS # UNDERLINE: \e[4 # BOLD: \e[1
  COLE='\\033[0m'  # RESET
  COLB='\\e[4;30m' # black
  COLR='\\e[4;31m' # red
  COLG='\\e[4;32m' # green
  COLY='\\e[4;33m' # yellow
  COLU='\\e[4;34m' # blue
  COLM='\\e[4;35m' # magenta
  COLC='\\e[4;36m' # cyan
  COLW='\\e[1;37m' # white
  REGEX_MAC='[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}'
  REGEX_UUID='[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'
  VM_DIR=/vm

__usage() {
  NAME=${0##*/}
  cat << HELP
usage:
  ${NAME}                -  list VMs
  ${NAME} -h | --help    -  print this help information
  ${NAME} -l | --unlock  -  unlock all locked VMs
  ${NAME} -m | --mac     -  check for duplicated MAC addresses in VMs
  ${NAME} -u | --uuid    -  check for duplicated UUID values in VMs

HELP
  exit 1
}

unalias vm    1> /dev/null 2> /dev/null
if ! which vm 1> /dev/null 2> /dev/null
then
  echo "NOPE: install 'sysutils/vm-bhyve-devel' package"
fi

case ${1} in
  (-h|--help|-help|help)
    __usage
    ;;

  (-l|--unlock)
    if [ "${VM_DIR}" != "" ]
    then
      cd ${VM_DIR}
      echo "INFO: VMs with 'run.lock' file:"
      ls */run.lock
      doas find ${VM_DIR} -name run.lock -delete
    fi
    exit 0
    ;;

  (-m|--mac)
    cd ${VM_DIR}
    CONFS_MACS_LIST=$( grep -i mac */*.conf )
    echo "${CONFS_MACS_LIST}" \
      | grep -i -o -E "${REGEX_MAC}" \
      | sort -n \
      | uniq -d -i \
      | while read MAC
        do
          echo "INFO: VMs with '${MAC}' mac address:"
          cd ${VM_DIR}
          grep -r -i ${MAC} */*.conf \
            | awk -F':' '{print $1}' \
            | sed -e 's|.conf||g' \
            | while read VM
              do
                echo "  ${VM##*/}"
              done
          echo
        done
    exit 0
    ;;

  (-u|--uuid)
    cd ${VM_DIR}
    CONFS_MACS_LIST=$( grep -i uuid */*.conf )
    echo "${CONFS_MACS_LIST}" \
      | grep -i -o -E "${REGEX_UUID}" \
      | sort -n \
      | uniq -d -i \
      | while read UUID
        do
          echo "INFO: VMs with '${UUID}' mac address:"
          cd ${VM_DIR}
          grep -r -i ${UUID} */*.conf \
            | awk -F':' '{print $1}' \
            | sed -e 's|.conf||g' \
            | while read VM
              do
                echo "  ${VM##*/}"
              done
          echo
        done
    exit 0
    ;;

esac

VM_LIST=$( doas vm list 2> /dev/null || sudo vm list 2> /dev/null )

while read LINE
do
  # GREEN COLOR FOR 'Running' MACHINES
  if echo "${LINE}" | grep -q ' Running (' 1> /dev/null 2> /dev/null
  then
    NEWLINE=$( echo "${LINE}" | sed "s/^/${COLG}/; s/$/${COLE}/" )
    echo -e "${NEWLINE}"
    continue
  fi

  # BLUE COLOR FOR 'Bootloader' MACHINES
  if echo "${LINE}" | grep -q ' Bootloader (' 1> /dev/null 2> /dev/null
  then
    NEWLINE=$( echo "${LINE}" | sed "s/^/${COLU}/; s/$/${COLE}/" )
    echo -e "${NEWLINE}"
    continue
  fi

  # RED COLOR FOR 'Locked' MACHINES
  if echo "${LINE}" | grep -q ' Locked (' 1> /dev/null 2> /dev/null
  then
    NEWLINE=$( echo "${LINE}" | sed "s/^/${COLR}/; s/$/${COLE}/" )
    echo -e "${NEWLINE}"
    continue
  fi

  # WHITE COLOR FOR HEADER
  if echo "${LINE}" | grep -q -E '^NAME.*STATE$' 1> /dev/null 2> /dev/null
  then
    NEWLINE=$( echo "${LINE}" | sed "s/^/${COLW}/; s/$/${COLE}/" )
    echo -e "${NEWLINE}"
    continue
  fi

  echo -e "${LINE}"

done << EOF
  $( echo "${VM_LIST}" )
EOF





