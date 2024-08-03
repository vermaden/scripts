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
# RANDOM WALLPAPER HANDLER
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

export DISPLAY=:0

__usage() {
  echo "usage: ${0##*/} DIR/FILE"
  exit 1
}

__absolute() {
  if [ -f "/${1}" ]
  then
    echo "${1}"
  else
    echo "$( pwd )/${1}"
  fi
}

[ ${#} -ne 1 ]             && __usage
[ -d "${1}" -o -f "${1}" ] || __usage

# DISABLE WHEN xfdesktop/wine/dosbox IS RUNNING
PS=$( ps axwww -o command | grep -E 'xfdesktop|winedevice.exe|dosbox' | grep -v grep )
if [ "${PS}" != "" ]
then
  exit 0
fi

# SINGLE FILE
if [ -f "${1}" ]
then
  FILE="${@}"
  WALL="/tmp/${0##*/}_${FILE##*/}.jpg"
fi

# DIRECTORY
if [ -d "${1}" ]
then
  WALLS_LIST=$( find "${1}" | egrep "^.*\.[pPjJgG][nNpPiI][gGeEfF][gG]*$" )
  WALLS_COUNT=$( echo "${WALLS_LIST}" | wc -l )
# RANDOM=$( head -c 256 /dev/urandom | env LC_ALL=C tr -c -d '1-9' )
  RANDOM=$( env LC_ALL=C tr -c -d '1-9' < /dev/random | head -c 16 )
  WINNER=$(( ${RANDOM} % ${WALLS_COUNT} + 1 ))
  FILE="$( echo "${WALLS_LIST}" | sed -n ${WINNER}p )"
fi

# MAKE BACKUP
cp ~/.fehbg ~/.fehbg.BCK

# SET WALLPAPER
case "${FILE}" in
  (*/TILE-*) feh --bg-tile  $( __absolute "${FILE}" ) 1> /dev/null 2> /dev/null ;;
  (*)        feh --bg-scale $( __absolute "${FILE}" ) 1> /dev/null 2> /dev/null ;;
esac


