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
# conky(1) IFACE/IP INFORMATION
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

# SETTINGS
WLAN=wlan0
WWAN=tun0
WWAN_FAIL=0

# WWAN DEBUG
# if [ ! -e /dev/cuaU0 ]
# then
#   echo -n "${WWAN}/FAIL "
#   WWAN_FAIL=1
# fi

case $( ifconfig -u | grep -v '127.0.0.1' | grep -c 'inet ' ) in
  (0)
    if [ ${WWAN_FAIL} -ne 1 ]
    then
      echo -n '- '
      exit 0
    fi
    ;;
  (*)
    for I in $( ifconfig -l -u | sed s/lo0//g )
    do
      if [ "${I}" = "${WWAN}" ]
      then
        if [ ${WWAN_FAIL} -eq 1 ]
        then
          continue
        fi
      fi
      IFCONFIG=$( ifconfig ${I} )
      if [ "${I}" = "${WLAN}" ]
      then
        echo -n ${I}
        SSID=$( echo "${IFCONFIG}" | grep 'ssid' )
        if echo "${SSID}" | grep -q '"'
        then
          SSID=$( echo "${IFCONFIG}" | awk -F \" '/ssid/ {print $2}' )
        else
          SSID=$( echo "${IFCONFIG}" | awk '/ssid/ {print $2}' )
        fi
        if [ "${SSID}" != "" ]
        then
          echo -n "/${SSID}"
        else
          echo -n "/-"
        fi
        SSID=''
        INET=$( echo "${IFCONFIG}" | awk '/inet / {print $2}' )
        echo "${INET}" \
          | while read IP
            do
              echo -n "/${IP}"
            done
        echo -n ' '
        INET=''
      else
        INET=$( echo "${IFCONFIG}" | awk '/inet / { printf("/%s",$2) }' )
        if [ "${INET}" != "" ]
        then
          echo -n "${I}${INET} "
        fi
        INET=''
      fi
    done
    ;;
esac
