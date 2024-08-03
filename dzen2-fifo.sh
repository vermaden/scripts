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
# DZEN2 FIFO
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

# SETTINGS
DELAY=60
FONT='Ubuntu Mono-10'
FG='#eeeeee'
BG='#222222'
NR="(sh|tail)\ .*dzen2-fifo"
ME=$$
# DOS='onstart=raise'
DOS='onstart=lower'
DB1='button1=exec:~/scripts/dzen2-update.sh > ~/.dzen2-fifo'
DB2='button2=exec:~/scripts/xdotool.sh workmenu'
DB3='button3=exec:~/scripts/xdotool.sh menu'
DB4='button4=exec:~/scripts/xdotool.sh down'
DB5='button5=exec:~/scripts/xdotool.sh up'
PS=$( ps axwww -o pid,command )

# KILL ALL ALIVE dzen2(1) PROCESSES
if echo "${PS}" | grep -q -E "${NR}" 2> /dev/null
then
  PIDS=$( echo "${PS}" | grep -E "${NR}" | awk '{print $1}' | grep -v ${ME} | tr '\n' ' ' )
  if [ ! -z "${PIDS}" ]
  then
    kill -9 ${PIDS}
  fi
fi

# CLEAN OLD dzen2(1) FIFO
rm -f ~/.dzen2-fifo

# MAKE NEW dzen2(1) FIFO
mkfifo ~/.dzen2-fifo

# START dzen2(1) TO UPDATE FIFO
while true
do
  tail -1 ~/.dzen2-fifo
done | dzen2 \
      -w 4096 \
      -fg "${FG}" \
      -bg "${BG}" \
      -fn "${FONT}" \
      -ta l \
      -e "${DOS};${DB1};${DB2};${DB3};${DB4};${DB5}" &

# RUN FITST dzen2(1) UPDATE
~/scripts/dzen2-update.sh > ~/.dzen2-fifo &
