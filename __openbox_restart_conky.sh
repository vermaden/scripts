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
# openbox(1) RESTART CONKY
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

#### XRANDR=$( xrandr )
#### COUNT=$( echo "${XRANDR}" | grep -c " connected " )
#### DELAY=0.2
PROFILE=T420s

killall -9 conky

nice -n 20 conky -c /home/vermaden/.conkyrc.1.9.${PROFILE}.LOG.1 1> /dev/null 2> /dev/null &
nice -n 20 conky -c /home/vermaden/.conkyrc.1.9.${PROFILE}.LOG.2 1> /dev/null 2> /dev/null &
nice -n 20 conky -c /home/vermaden/.conkyrc.1.9.${PROFILE}.LOG.3 1> /dev/null 2> /dev/null &
nice -n 20 conky -c /home/vermaden/.conkyrc.1.9.${PROFILE}.LOG.4 1> /dev/null 2> /dev/null &
nice -n 20 conky -c /home/vermaden/.conkyrc.1.9.${PROFILE}.LOG.5 1> /dev/null 2> /dev/null &
nice -n 20 conky -c /home/vermaden/.conkyrc.1.9.${PROFILE}.LOG.6 1> /dev/null 2> /dev/null &
nice -n 20 conky -c /home/vermaden/.conkyrc.1.9.${PROFILE}.LOG.7 1> /dev/null 2> /dev/null &
nice -n 20 conky -c /home/vermaden/.conkyrc.1.9.${PROFILE}.LOG.8 1> /dev/null 2> /dev/null &
nice -n 20 conky -c /home/vermaden/.conkyrc.1.9.${PROFILE}.LOG.9 1> /dev/null 2> /dev/null &

echo '1' >> ~/scripts/stats/$( basename ${0} )
