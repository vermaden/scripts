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

__usage() {
  NAME=${0##*/}
  cat << HELP
usage:
  ${NAME} <OPTION> [VM]

option(s):
  -l  list paused VMs
  -p  VM pause
  -r  VM resume
  -R  resumes ALL paused VMs to running state
  -t  VM toggle between pause and resume

example(s):
  # ${NAME} -l
  # ${NAME} -R
  # ${NAME} -p freebsd-14.1
  # ${NAME} -t netbsd-test-vm

HELP
  exit 1
}

[ ${#} -ne 2 -a ${#} -ne 1 ] && __usage

case ${1} in

  (-R)
    ;;

  (-p|-r|-t)

    unalias vm    1> /dev/null 2> /dev/null
    if ! which vm 1> /dev/null 2> /dev/null
    then
      echo "NOPE: install 'sysutils/vm-bhyve-devel' package"
    fi

    VM_LIST=$( doas vm list 2> /dev/null || sudo vm list 2> /dev/null )
    VM=$( echo "${VM_LIST}" | grep -m 1 "^${2} " | awk '{print $1}' )
    if [ "${VM}" = "" ]
    then
      echo "NOPE: virtual machine '${2}' does not exist"
      exit 1
    fi

    while read NAME DATASTORE LOADER CPU MEMORY VNC AUTO STATE GARBAGE
    do
      if [ "${STATE}" != "Running" ]
      then
        echo "NOPE: virtual machine '${2}' is stopped"
      exit 1
      fi
    done << ECHO
      $( echo "${VM_LIST}" | grep -m 1 "^${2} " )
ECHO

    PID=$( ps aww | grep -v grep | grep "bhyve: ${VM} (bhyve)" | awk '{print $1}' )

    unset VM_LIST
    ;;

  (-l)

    (
      echo "   PID VM"

      ps -U root -o state,pid,command \
        | grep 'bhyve:' \
        | grep '^T' \
        | grep -v '^Ts+' \
        | sed -e 's|(bhyve)||g' \
              -e 's|bhyve:||g' \
        | awk '{$1=""; print $0}'
    ) | column -t

    exit 0
    ;;

  (*)
    __usage
    ;;

esac

case ${1} in

  (-p)

    kill -STOP ${PID} 2> /dev/null || {
      echo "NOPE: permission denied"
      exit 1
    }

    echo "INFO: VM ${VM} - # kill -STOP ${PID}"
    ;;

  (-r)

    kill -CONT ${PID} 2> /dev/null || {
      echo "NOPE: permission denied"
      exit 1
    }

    echo "INFO: VM ${VM} - # kill -CONT ${PID}"
    ;;

  (-R)
    ${0} -l \
      | sed 1d \
      | awk '{print $1}' \
      | while read PID
        do
          kill -CONT ${PID} 2> /dev/null || {
            echo "NOPE: permission denied"
            exit 1
          }
          echo "INFO: VM ${VM} - # kill -CONT ${PID}"
        done
    ;;

  (-t)

    STATE=$( ps -o state ${PID} | sed 1d )

    case ${STATE} in
      (I*|S*|R*) SIGNAL=STOP ;;
      (T*)       SIGNAL=CONT ;;
      (*)
        echo "NOPE: not supported '${STATE}' process state."
        exit 1
        ;;
    esac

    kill -${SIGNAL} ${PID} 2> /dev/null || {
      echo "NOPE: permission denied"
      exit 1
    }

    echo "INFO: VM ${VM} - # kill -${SIGNAL} ${PID}"
    ;;

  (*)

    __usage
    ;;

esac

# NOTES
# vm list | awk '{a=NF; print $a; b=a-1; print $b}'

