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
# openbox(1) LOCK
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

# ONE TIME TRY TO START mate-screensaver IF IT DOES NOT RUN
if pgrep -q mate-screensaver 1> /dev/null 2> /dev/null
then
  mate-screensaver 1> /dev/null 2> /dev/null &
fi

# FALLBACK TO xlockmore WHEN mate-screensaver DOES NOT RUN
if pgrep -q mate-screensaver 1> /dev/null 2> /dev/null
then
  mate-screensaver-command --lock 1> /dev/null 2> /dev/null
else
  FONT='-*-fixed-*-*-*-*-10-*-*-*-*-*-iso8859-2'
  FONT='-*-clean-*-*-*-*-*-*-*-*-*-*-iso8859-2'

  xlock \
    -mode image \
    -planfontset "${FONT}" \
    -fontset     "${FONT}" \
    -username 'user: ' \
    -password 'pass:' \
    -info ' ' \
    -validate 'Checking.' \
    -invalid 'Nope. ' \
    -background gray20 \
    -foreground gray60 \
    -dpmsoff 1 \
    -icongeometry 64x64 \
    -echokeys \
    -echokey '*' \
    -bitmap /home/vermaden/.icons/vermaden/xlock.xpm \
    -count 1 \
    -delay 10000000 \
    -erasemode no_fade \
    +showdate \
    +description

# xlock \
#   -mode blank \
#   -planfontset "${FONT}" \
#   -fontset     "${FONT}" \
#   -username 'user: ' \
#   -password 'pass:' \
#   -info ' ' \
#   -validate 'Checking.' \
#   -invalid 'Nope. ' \
#   -background gray20 \
#   -foreground gray60 \
#   -dpmsoff 1 \
#   -icongeometry 1x1 \
#   -echokeys \
#   -echokey '*' \
#   +showdate \
#   +description

fi

echo '1' >> ~/scripts/stats/${0##*/}
