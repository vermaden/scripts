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

__usage() {
  echo "usage: ${0##*/} TYPE"
  echo
  echo "type: dzen2 | conky"
  echo
  exit 1
}

# SETTINGS
# URL=$( __conky_if_dns.sh )
# URL=freebsd.org
  URL=96.47.72.84
  DELAY=1.25

# TYPE
case ${1} in
  (conky|dzen2) :       ;;
  (*)           __usage ;;
esac

# WAIT 2 SECONDS WITH -t OPTION
if ping -c 1 -s 0 -t ${DELAY} -q ${URL} 1> /dev/null 2> /dev/null
then
  echo -n OK
else
  case ${1} in
    (conky) printf "%s" "\${color ${COLOR}}NOPE\${color}" ;;
    (dzen2) echo "^fg(RED)NOPE" ;;
  esac
fi
