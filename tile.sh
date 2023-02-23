#! /bin/sh

# Copyright (c) 2023 Slawomir Wojciech Wojtczak (vermaden)
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
# TILE WINDOWS IN X11 SYSTEM
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

__swap() { # 1=WINDOWS
  LINES=$( echo "${1}" | wc -l | awk '{print $1}' )
  [ ${LINES} -eq 0 ] && exit 0
  [ -f ${STATE} ] || {
    echo "ERROR: file '${STATE}' does not exists"
    exit 1
  }
  SHIFT=$(( $( cat ${STATE} ) + 1 ))
  SHIFT=$(( SHIFT % ${LINES} ))
  echo ${SHIFT} > ${STATE}
  [ ${SHIFT} -eq 0 ] && {
    echo "${1}"
    exit 0
  }
  CURRENT="${1}"
  for I in $( jot ${SHIFT} )
  do
    FIRST=$( echo "${CURRENT}" | head -1 )
    CURRENT=$( echo "${CURRENT}" | sed 1d; echo "${FIRST}" )
  done
  echo "${CURRENT}"
}

__tile() { # 1=WINDOWS 2=ACTIVE_PID
  COUNT=$( echo "${1}" | wc -l )
  [ ${COUNT} -gt 1 ] || exit 0
  WIDTH=$(( ${MAX_W} * ${RATIO} / 100 ))
  HEIGHT=$(( ${MAX_H} - ${TITLE} ))
  case ${#} in
    (1) MAIN=$( echo "${1}" | head -1 | awk '{print $1}' ) ;;
    (2) MAIN=$( echo "${1}" | grep "${2}" | awk '{print $1}' ) ;;
  esac
  wmctrl -i -r ${MAIN} -e 0,${PAD_L},${PAD_T},${WIDTH},${HEIGHT}
  POS_X=$(( ${WIDTH} + ${BORDER} ))
  WIDTH=$(( ${MAX_W} - ${WIDTH} - ( ${BORDER} * 2 ) ))
  COUNT=$(( COUNT - 1 ))
  # HEIGHT=$(( ( ( ${MAX_H} - ${PAD_T} - ${PAD_B} ) / ${COUNT} ) - ${TITLE} ))
  HEIGHT=400
  NUM=-1
  ALIGN=""
  STATIC=""
  echo "${1}" \
    | grep -v "${MAIN}" \
    | awk '{print $1}' \
    | while read ID
      do
        NUM=$(( ${NUM} + 1 ))
        [ $(( ${COUNT} - 1 )) -eq ${NUM} ] && \
          LAST="+$(( ${MAX_H} - ${PAD_T} - ${PAD_B} - ( ${NUM} * ${HEIGHT} ) - ${HEIGHT} - ( 2 * ${BORDER} ) ))"
        wmctrl -i -r ${ID} -e 0,${POS_X},$(( ${PAD_T} + ( ${NUM} * ${HEIGHT} ) + ( ${NUM} * ( ${BORDER} + 1 ) * 5 ) ${STATIC} )),${WIDTH},$(( ${HEIGHT} ${STATIC_HEIGHT} ${LAST} ))
        [ ${#ALIGN} -eq 0 ] || ALIGN=""
        SIZE_H=$( wmctrl -l -G | grep -E "^${ID}" | awk '{print $6}' )
        [ ${HEIGHT} -lt ${SIZE_H} ] && ALIGN="+ $(( ${SIZE_H} - ${HEIGHT} ))"
        [ ${HEIGHT} -gt ${SIZE_H} ] && ALIGN="- $(( ${HEIGHT} - ${SIZE_H} ))"
        [ ${#ALIGN} -eq 0 -a ${#STATIC} -eq 0 ] && STATIC="" || STATIC=$(( ${STATIC} ${ALIGN} ))
        [ "${STATIC}" = "" ] || {
          [ ${STATIC} -gt 0 ] && STATIC="+${STATIC}"
          [ ${STATIC} -eq 0 ] && STATIC="+0"
          [ ${STATIC} -lt 0 ] && STATIC_HEIGHT="+ $(( ${STATIC} * (-1) ))"
        }
      done
}

__double() { # 1=WINDOWS 2=ACTIVE_PID
  COUNT=$( echo "${1}" | wc -l )
  [ ${COUNT} -gt 1 ] || exit 0
  [ ${COUNT} -lt 3 ] && {
    ${0##*/} tile
    exit 0
  }
  WIDTH=$(( ${MAX_W} * ${RATIO} / 100 ))
  HEIGHT=$(( ( ${MAX_H} ) / 2 ))
  case ${#} in
    (1) MAIN=$( echo "${1}" | head -1 | awk '{print $1}' ) ;;
    (2) MAIN=$( echo "${1}" | grep "${2}" | awk '{print $1}' ) ;;
  esac
  wmctrl -i -r ${MAIN} -e 0,${PAD_L},${PAD_T},${WIDTH},${HEIGHT}
  WINDOWS=$( echo "${1}" | grep -v "${MAIN}" )
  SIZE_H=$(( $( wmctrl -l -G | grep -E "^${MAIN}" | awk '{print $6}' ) + 10 ))
  [ ${HEIGHT} -lt ${SIZE_H} ] && ALIGN="+ $(( ${SIZE_H} - ${HEIGHT} ))"
  [ ${HEIGHT} -gt ${SIZE_H} ] && ALIGN="- $(( ${HEIGHT} - ${SIZE_H} ))"

  MAIN=$( echo "${WINDOWS}" | head -1 | awk '{print $1}' )
  SECOND=$(( ${MAX_H} - ${PAD_T} - ${PAD_B} - ${HEIGHT} - ${TITLE} ))

  wmctrl -i -r ${MAIN} -e 0,${PAD_L},$(( ${HEIGHT} + ( ${TITLE} * 2 ) - 1 ${ALIGN} )),${WIDTH},$(( ${SECOND} ${ALIGN} ))
  POS_X=$(( ${WIDTH} + ${BORDER} ))
  WIDTH=$(( ${MAX_W} - ${WIDTH} - ( ${BORDER} * 2 ) ))
  COUNT=$(( COUNT - 2 ))
  HEIGHT=$(( ( ( ${MAX_H} - ${PAD_T} - ${PAD_B} - ${TITLE} - ${BORDER} ) / ${COUNT} ) - ( ${TITLE} + ${BORDER} ) ))
  NUM=-1
  ALIGN=""
  STATIC=""
  echo "${WINDOWS}" \
    | grep -v "${MAIN}" \
    | awk '{print $1}' \
    | while read ID
      do
        NUM=$(( ${NUM} + 1 ))
        [ $(( ${COUNT} - 1 )) -eq ${NUM} ] && \
          LAST="+$(( ${MAX_H} - ${PAD_T} - ${PAD_B} - ( ( ${NUM} + 1 ) * ${HEIGHT} ) - ( ${NUM} * ${BORDER} ) - ${TITLE} ))"
        wmctrl -i -r ${ID} -e 0,${POS_X},$(( ${PAD_T} + ( ${NUM} * ${HEIGHT} ) + ( ${NUM} * ( ${BORDER} + 1 ) * 5 ) ${STATIC} )),${WIDTH},$(( ${HEIGHT} ${STATIC_HEIGHT} ${LAST} ))
        [ ${#ALIGN} -eq 0 ] || ALIGN=""
        SIZE_H=$( wmctrl -l -G | grep -E "^${ID}" | awk '{print $6}' )
        [ ${HEIGHT} -lt ${SIZE_H} ] && ALIGN="+ $(( ${SIZE_H} - ${HEIGHT} ))"
        [ ${HEIGHT} -gt ${SIZE_H} ] && ALIGN="- $(( ${HEIGHT} - ${SIZE_H} ))"
        [ ${#ALIGN} -eq 0 -a ${#STATIC} -eq 0 ] && STATIC="" || STATIC=$(( ${STATIC} ${ALIGN} ))
        [ "${STATIC}" = "" ] || {
          [ ${STATIC} -gt 0 ] && STATIC="+${STATIC}"
          [ ${STATIC} -eq 0 ] && STATIC="+0"
          [ ${STATIC} -lt 0 ] && STATIC_HEIGHT="+ $(( ${STATIC} * (-1) ))"
        }
      done
}
STATE=/tmp/${0##*/}.state
[ -f ${STATE} ] || echo 0 > ${STATE}

WMCTRL_D=$( wmctrl -d )
WORKSPACE=$( echo "${WMCTRL_D}" | awk '/\*/ {print $1}' )
RES=$( echo "${WMCTRL_D}" | grep -o -E "\* DG:\ [0-9]+x[0-9]+" | awk '{print $3}' | tr 'x' ' ' )
RES_W=$( echo "${RES}" | awk '{print $1}' )
RES_H=$( echo "${RES}" | awk '{print $2}' )
WINDOWS=$( wmctrl -l -p | awk -v WORKSPACE=${WORKSPACE} '{if($2==WORKSPACE) print $1 " " $2 " " $3 }' )
ACTIVE_PID=$( xdotool getactivewindow getwindowpid 2> /dev/null )

PAD_B=0; PAD_T=31; PAD_L=0; PAD_R=0; RATIO=55; ADJUST=4; TITLE=21; BORDER=3
[ -f /usr/local/etc/tile.conf ] && . /usr/local/etc/tile.conf

MAX_W=$(( ${RES_W} - ${PAD_L} - ${PAD_R} ))
MAX_H=$(( ${RES_H} - ${PAD_T} - ${PAD_B} ))

case ${1} in
  (left)
    wmctrl -r :ACTIVE: -e 0,${PAD_L},${PAD_T},$(( ${MAX_W} / 2 - 1 )),${MAX_H}
    ;;
  (right)
    wmctrl -r :ACTIVE: -e 0,$(( ${MAX_W} / 2 )),${PAD_T},$(( ${MAX_W} / 2 - 1 )),${MAX_H}
    ;;
  (tile)
    __tile "${WINDOWS}" "${ACTIVE_PID}"
    ;;
  (tile-swap)
    WINDOWS=$( __swap "${WINDOWS}" )
    __tile "${WINDOWS}"
    ;;
  (double)
    __double "${WINDOWS}" "${ACTIVE_PID}"
    ;;
  (double-swap)
    WINDOWS=$( __swap "${WINDOWS}" )
    __double "${WINDOWS}"
    ;;

esac
