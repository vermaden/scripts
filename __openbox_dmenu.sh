#! /bin/sh

# Copyright (c) 2018-2026 Slawomir Wojciech Wojtczak (vermaden)
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
# openbox(1) WITH dmenu(1)
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

# find /usr/local/sbin \
#      /usr/local/bin \
#      /home/vermaden/scripts \
#      /home/vermaden/scripts/bin \
#      /home/vermaden/.cargo/bin \
#      /home/vermaden/.local/bin \
#      -type f 2> /dev/null \
#   | while read I
#     do
#       builtin echo ${I##*/}
#     done > ~/.cache/dmenu_run

# CLEAR LIST OF APPS
:> ~/.cache/dmenu_run

# ADD APPS FROM GLOBAL /usr/local/share/applications PATH
grep -h '^Exec=' /usr/local/share/applications/* \
  | awk -F '=' '{print $2}' \
  | awk '{print $1}' \
  | sort -u \
  | grep -v -e 'bin/sh' \
  | while read APP
    do
      echo "${APP##*/}"
    done >> ~/.cache/dmenu_run

# ADD APPS FROM LOCAL ~/.cargo/bin PATH
find /home/vermaden/.cargo/bin -type f 2> /dev/null \
  | while read APP
    do
      ldd -f '%o ' "${APP}" 2> /dev/null \
        | grep -q -e libgtk -e libQt -e libxcb && echo "${APP##*/}"
    done >> ~/.cache/dmenu_run

# RUN
CHOICE=$( cat ~/.cache/dmenu_run | dmenu -i -nb '#222222' -nf '#aaaaaa' -sb '#eeeeee' -sf '#dd0000' -fn 'Ubuntu Mono-10' ${1+"${@}"} )

# EXIT IF NO CHOICE
if [ -z "${CHOICE}" ]
then
  exit 0
fi

# EXECUTE
CMD=$( which "${CHOICE}" )
TITLE=${CMD##*/}

# XTERM OR NOT EXCEPTIONS
if echo "${CMD}" | grep -q -i virtualbox; then "${CMD}" & exit 0; fi
if echo "${CMD}" | grep -q -i audacious;  then "${CMD}" & exit 0; fi
if echo "${CMD}" | grep -q -i deadbeef;   then "${CMD}" & exit 0; fi
if echo "${CMD}" | grep -q -i vlc;        then "${CMD}" & exit 0; fi

# XTERM OR NOT
if ldd "${CMD}" | grep -q libX11
then
  "${CMD}" &
else
  xterm -title "${TITLE}" -e "${CMD};read" &
fi
