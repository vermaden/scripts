#! /bin/sh

# Copyright (c) 2025 Slawomir Wojciech Wojtczak (vermaden)
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
# SHOW FreeBSD BATTERY STATUS
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

BATS=$( sysctl -n hw.acpi.battery.units )
LIFE=$( sysctl -n hw.acpi.battery.life )
case $( sysctl -n hw.acpi.acline ) in
  (1)
    BAT0STATE=$( acpiconf -i 0 | awk '/^State:/ {print $2}' )
    if [ "${BAT0STATE}" != "not" ]
    then
      BAT0=$( acpiconf -i 0 | awk '/^Remaining capacity:/ {print $3}' )
    else
      BAT0="-"
    fi
    BAT1STATE=$( acpiconf -i 1 | awk '/^State:/ {print $2}' )
    if [ "${BAT1STATE}" != "not" ]
    then
      BAT1=$( acpiconf -i 1 | awk '/^Remaining capacity:/ {print $3}' )
    else
      BAT1="-"
    fi
    echo "time: AC"
    echo "bat0: ${BAT0}"
    echo "bat1: ${BAT1}"
    ;;
  (0)
    TIME=$( sysctl -n hw.acpi.battery.time )
    if [ "${TIME}" != "-1" ]
    then
      HOUR=$(( ${TIME} / 60 ))
      MINS=$(( ${TIME} % 60 ))
      [ ${MINS} -lt 10 ] && MINS="0${MINS}"
    else
      # WE HAVE TO ASSUME SOMETHING SO LETS ASSUME 2:22
      TIME=0
      HOUR=0
      MINS=0
    fi

    case ${BATS} in
      (1)
        echo "${HOUR}:${MINS}/${LIFE}"
        ;;
      (2)
        BAT0STATE=$( acpiconf -i 0 | awk '/^State:/ {print $2}' )
        if [ "${BAT0STATE}" != "not" ]
        then
          BAT0=$( acpiconf -i 0 | awk '/^Remaining capacity:/ {print $3}' )
        else
          BAT0="-"
        fi
        BAT1STATE=$( acpiconf -i 1 | awk '/^State:/ {print $2}' )
        if [ "${BAT1STATE}" != "not" ]
        then
          BAT1=$( acpiconf -i 1 | awk '/^Remaining capacity:/ {print $3}' )
        else
          BAT1="-"
        fi
        echo "time: ${HOUR}:${MINS}"
        echo "bat0: ${BAT0}"
        echo "bat1: ${BAT1}" 
        ;;
    esac
    ;;
esac
