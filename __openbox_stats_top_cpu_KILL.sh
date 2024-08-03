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
# openbox(1) STATS TOP CPU KILL
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

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
echo "<openbox_pipe_menu>"

HEAD=1
top -b \
  | grep -A 11 "PID USERNAME" 2> /dev/null \
  | awk '{ printf("| %5s %4s %7s %6s %-20s\n",$1,$5,$11,$10,$12); }' \
  | while read LINE
    do
      [ ${HEAD} ] && {
        echo "<separator label=\"${LINE}\" />"
        unset HEAD
        continue
      }
      PID=$(  echo "${LINE}" | awk '{print $2}' )
      LINE=$( echo "${LINE}" | sed s/_/__/g )
      echo "<item label=\"${LINE}\">"
      echo "  <action name=\"Execute\">"
      echo "    <command>${CMD} kill -9 ${PID}</command>"
      echo "  </action>"
      echo "</item>"
    done

echo "</openbox_pipe_menu>"
