#! /bin/sh

# Copyright (c) 2021 Slawomir Wojciech Wojtczak (vermaden)
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
# MAPS FILE AS DEVICE ON FREEBSD
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

if ! which doas 1> /dev/null 2> /dev/null
then
  echo "ERROR: this script needs 'doas' to work"
  exit 1
fi

__usage() {
  NAME="${0##*/}"
  echo "usage: ${0##*/} OPTION FILE|DEVICE"
  echo
  echo "options:  -l --list   - list existing vnode(s)"
  echo "          -c --create - create new vnode"
  echo "          -d --delete - delete existing vnode"
  echo
  echo "examples: ${NAME} -c ~/FILE"
  echo "          ${NAME} -d 0"
  echo "          ${NAME} -l"
  echo
  exit 1
}

# ONLY WORKS WITH 1 OR 2 ARGUMENTS
[ ${#} -eq 2 -o ${#} -eq 1 ] || __usage

case ${1} in
  (-l|--list)
    doas mdconfig -l -v
    ;;

  (-c|--create)
    [ ${#} -eq 2 ] || __usage
    [ -f ${2} ] || {
      echo "ER: file '${2}' does not exist"
      echo
      __usage
    }
    echo -n "IN: created vnode at /dev/"
    doas mdconfig -a -t vnode -f ${2}
    ;;

  (-d|--delete)
    [ ${#} -eq 2 ] || __usage

    [ -c ${2} ]        && DEV=${2}        # /dev/md0
    [ -c /dev/${2} ]   && DEV=/dev/${2}   # md0
    [ -c /dev/md${2} ] && DEV=/dev/md${2} # 0

    [ ${DEV} ] || {
      echo "ER: device '${2}' does not exist"
      echo
      __usage
    }

    doas mdconfig -d -u ${DEV}
    echo "IN: deleted vnode at ${DEV}"
    ;;

  (*)
    __usage

esac

# mdconfig -l -v
# mdconfig -d -u 0
# mdconfig -a -t vnode -f FILE
