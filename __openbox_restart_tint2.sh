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
# openbox(1) RESTART TINT2
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

XRANDR=$( xrandr )
COUNT=$( echo "${XRANDR}" | grep -c " connected " )
DELAY=0.1

killall -9 tint2

__builtin() {
# ( sleep ${DELAY} &&            tint2 -c ~/.tint2rc.STARTER 1> /dev/null 2> /dev/null ) &
# ( sleep ${DELAY} && nice -n 20 tint2 -c ~/.tint2rc         1> /dev/null 2> /dev/null ) &
  ( sleep ${DELAY} &&            tint2 -c ~/.tint2rc.ALL     1> /dev/null 2> /dev/null ) &
}

__right() {
  ( sleep ${DELAY} &&            tint2 -c ~/.tint2rc.STARTER.RIGHT 1> /dev/null 2> /dev/null ) &
  ( sleep ${DELAY} && nice -n 20 tint2 -c ~/.tint2rc.RIGHT         1> /dev/null 2> /dev/null ) &
}

__builtin
case ${COUNT} in
  (2)
    ENABLED=$( echo "${XRANDR}" | grep " connected " | grep -c -E "[0-9]+mm\ x\ [0-9]+mm" )
    case ${ENABLED} in
      (2)
        __right
        ;;
    esac
    ;;
esac

echo '1' >> ~/scripts/stats/$( basename ${0} )
