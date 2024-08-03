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
# BATTERY CAPACITY TESTER
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

if [ ${#} -ne 1 -a ${#} -ne 0 ]
then
  echo "usage: ${0##*/} BATTERY"
  exit
fi

if [ "${1}" = "" ]
then
  BAT=0
else
  BAT=${1}
fi

if acpiconf -i ${BAT} 1> /dev/null 2> /dev/null
then
  DATA=$( acpiconf -i ${BAT} )
  MAX=$( echo "${DATA}" | grep '^Design\ capacity:'     | awk -F ':' '{print $2}' | tr -c -d '0-9' )
  NOW=$( echo "${DATA}" | grep '^Last\ full\ capacity:' | awk -F ':' '{print $2}' | tr -c -d '0-9' )
  MOD=$( echo "${DATA}" | grep '^Model\ number:'        | awk -F ':' '{print $2}' | awk '{print $1}' )
  echo -n "Battery '${BAT}' model '${MOD}' has efficiency: "
  printf '%1.0f%%\n' $( bc -l -e "scale = 2; ${NOW} / ${MAX} * 100" -e quit )
else
  echo "NOPE: Battery '${BAT}' does not exists on this system."
  echo "INFO: Most systems has only '0' or '1' batteries."
  exit 1
fi
