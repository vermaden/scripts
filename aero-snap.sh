#! /bin/sh

# Copyright (c) 2021 Slawomir Wojciech Wojtczak (vermaden)
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
# OPEN SOURCE AERO SNAP EXTENDED
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

OVERHEAD_X=6
OVERHEAD_Y=5
MARGIN_TOP=29
MARGIN_LEFT=1
MARGIN_RIGHT=1
XDPYINFO=$( xdpyinfo | awk '/dimension/ {print $2}' )

snap() {
  SCREEN_W=$( echo "${XDPYINFO}" | awk -F 'x' '{print $1}' )
  SCREEN_H=$( echo "${XDPYINFO}" | awk -F 'x' '{print $2}' )
  case ${1} in
    (L)
      wmctrl -r :ACTIVE: -b remove,maximized_horz
      wmctrl -r :ACTIVE: -e 0,${MARGIN_LEFT},-1,$(( ( ${SCREEN_W} / 2 ) - ${MARGIN_LEFT} - ${OVERHEAD_X} )),-1
      wmctrl -r :ACTIVE: -b add,maximized_vert
      ;;
    (R)
      wmctrl -r :ACTIVE: -b remove,maximized_horz
      wmctrl -r :ACTIVE: -e 0,$(( ( ${SCREEN_W} / 2 ) -1 )),-1,$(( ( ${SCREEN_W} / 2 ) - 3 - ${MARGIN_RIGHT} )),-1
      wmctrl -r :ACTIVE: -b add,maximized_vert
      ;;
    (SHIFT-L)
      wmctrl -r :ACTIVE: -b remove,maximized_horz
      wmctrl -r :ACTIVE: -e 0,${MARGIN_LEFT},-1,$(( ( ${SCREEN_W} / 3 * 2 ) - ${MARGIN_LEFT} - ${OVERHEAD_X} )),-1
      wmctrl -r :ACTIVE: -b add,maximized_vert
      ;;
    (SHIFT-R)
      wmctrl -r :ACTIVE: -b remove,maximized_horz
      wmctrl -r :ACTIVE: -e 0,$(( ( ${SCREEN_W} / 3 * 2 ) - 1 )),-1,$(( ( ${SCREEN_W} / 3 ) - 3 - ${MARGIN_RIGHT} + 1 )),-1
      wmctrl -r :ACTIVE: -b add,maximized_vert
      ;;
    (T)
      X=${MARGIN_LEFT}
      Y=${MARGIN_TOP}
      H=$(( ( ${SCREEN_H} / 2 ) - ${MARGIN_TOP} ))
      wmctrl -r :ACTIVE: -b remove,maximized_vert
      wmctrl -r :ACTIVE: -e 0,${X},${Y},$(( ${SCREEN_W} - ${MARGIN_LEFT} - 4 )),$(( ${H} ))
      ;;
    (B)
      X=${MARGIN_LEFT}
      Y=$(( ( ${SCREEN_H} / 2 ) + ${MARGIN_TOP} + 5 ))
      H=$(( ( ${SCREEN_H} / 2 ) - ${MARGIN_TOP} - 3 ))
      wmctrl -r :ACTIVE: -b remove,maximized_vert
      wmctrl -r :ACTIVE: -e 0,${X},$(( ${Y} - 8 )),$(( ${SCREEN_W} - ${MARGIN_LEFT} - 4 )),$(( ${H} - 20 ))
      ;;
    (SHIFT-T)
      X=${MARGIN_LEFT}
      Y=${MARGIN_TOP}
      H=$(( ( ${SCREEN_H} / 3 * 2 ) - ${MARGIN_TOP} ))
      wmctrl -r :ACTIVE: -b remove,maximized_vert
      wmctrl -r :ACTIVE: -e 0,${X},${Y},$(( ${SCREEN_W} - ${MARGIN_LEFT} - 4 )),$(( ${H} ))
      ;;
    (SHIFT-B)
      X=${MARGIN_LEFT}
      Y=$(( ( ${SCREEN_H} / 3 * 2) + ${MARGIN_TOP} + 5 ))
      H=$(( ( ${SCREEN_H} / 3 )    - ${MARGIN_TOP} - 3 ))
      wmctrl -r :ACTIVE: -b remove,maximized_vert
      wmctrl -r :ACTIVE: -e 0,${X},$(( ${Y} - 8 )),$(( ${SCREEN_W} - ${MARGIN_LEFT} - 5 )),$(( ${H} - 20 ))
      ;;
    (C)
      X=$(( ${SCREEN_W} / 9 ))
      Y=$(( ${SCREEN_H} / 8 ))
      W=$( echo "${SCREEN_W} / 1.30" | bc -l | awk -F '.' '{print $1}' )
      H=$( echo "${SCREEN_H} / 1.30" | bc -l | awk -F '.' '{print $1}' )
      wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
      wmctrl -r :ACTIVE: -e 0,${X},${Y},${W},${H}
      ;;
    (F)
      wmctrl -r :ACTIVE: -b toggle,maximized_vert,maximized_horz
      exit 0
      ;;
    (Q)
      wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
      exit 0
      ;;
    (TL)
      X=${MARGIN_LEFT}
      Y=${MARGIN_TOP}
      wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
      wmctrl -r :ACTIVE: -e 0,${X},${Y},$(( ( ${SCREEN_W} / 2 ) - ${MARGIN_LEFT} - 4 )),$(( ( ${SCREEN_H} / 2 ) - ${MARGIN_TOP} - 4 )),-1
      ;;
    (TR)
      X=$(( ( ${SCREEN_W} / 2 ) - 1 ))
      Y=${MARGIN_TOP}
      wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
      wmctrl -r :ACTIVE: -e 0,${X},${Y},$(( ( ${SCREEN_W} / 2 ) - 4 )),$(( ( ${SCREEN_H} / 2 ) - ${MARGIN_TOP} )),-1
      ;;
    (BL)
      X=${MARGIN_LEFT}
      Y=$(( ( ${SCREEN_H} / 2 ) + ${MARGIN_TOP} - ( ${MARGIN_TOP} / 4 ) ))
      wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
      wmctrl -r :ACTIVE: -e 0,${X},${Y},$(( ${SCREEN_W} / 2 )),$(( ( ${SCREEN_H} / 2 ) - ${MARGIN_TOP} - ( ${MARGIN_TOP} / 2 ) )),-1
      ;;
    (BR)
      X=$(( ( ${SCREEN_W} / 2 ) + ${MARGIN_LEFT} ))
      Y=$(( ( ${SCREEN_H} / 2 ) + ${MARGIN_TOP} - ( ${MARGIN_TOP} / 4 ) ))
      wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
      wmctrl -r :ACTIVE: -e 0,${X},${Y},$(( ${SCREEN_W} / 2 )),$(( ( ${SCREEN_H} / 2 ) - ${MARGIN_TOP} - ( ${MARGIN_TOP} / 2 ) )),-1
      ;;
    (SHIFT-TL)
      X=${MARGIN_LEFT}
      Y=${MARGIN_TOP}
      wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
      wmctrl -r :ACTIVE: -e 0,${X},${Y},$(( ( ${SCREEN_W} / 3 * 2 ) - ${MARGIN_LEFT} - 4 )),$(( ( ${SCREEN_H} / 3 * 2 ) - ${MARGIN_TOP} - 3 )),-1
      ;;
    (SHIFT-TR)
      X=$(( ( ${SCREEN_W} / 3 * 2 ) + 1 ))
      Y=${MARGIN_TOP}
      wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
      wmctrl -r :ACTIVE: -e 0,${X},${Y},$(( ( ${SCREEN_W} / 3 ) - 5 )),$(( ( ${SCREEN_H} / 3 * 2 ) - ${MARGIN_TOP} - 3 )),-1
      ;;
    (SHIFT-BL)
      X=${MARGIN_LEFT}
      Y=$(( ( ${SCREEN_H} / 3 * 2 ) + ${MARGIN_TOP} - ( ${MARGIN_TOP} / 4 ) + 1 ))
      wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
      wmctrl -r :ACTIVE: -e 0,${X},${Y},$(( ( ${SCREEN_W} / 3 * 2 ) - 5 )),$(( ( ${SCREEN_H} / 3 ) - ${MARGIN_TOP} - ( ${MARGIN_TOP} / 2 ) - 6 )),-1
      ;;
    (SHIFT-BR)
      X=$(( ( ${SCREEN_W} / 3 * 2 ) + ${MARGIN_LEFT} ))
      Y=$(( ( ${SCREEN_H} / 3 * 2 ) + ${MARGIN_TOP} - ( ${MARGIN_TOP} / 4 ) + 1 ))
      wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
      wmctrl -r :ACTIVE: -e 0,${X},${Y},$(( ${SCREEN_W} / 3 - 5 )),$(( ( ${SCREEN_H} / 3 ) - ${MARGIN_TOP} - ( ${MARGIN_TOP} / 2 ) - 6 )),-1
      ;;
    (*)
      NAME=${0##*/}
      echo "usage:"
      echo
      echo "  ${0##*/} OPTION"
      echo
      echo "OPTION(s):"
      echo
      echo "  L - place window on left  half of screen"
      echo "  R - place window on right half of screen"
      echo "  T - place window on upper half of screen"
      echo "  B - place window on lower half of screen"
      echo
      echo "  SHIFT-L - place window on left  half of screen taking 2/3 space"
      echo "  SHIFT-R - place window on right half of screen taking 1/3 space"
      echo "  SHIFT-T - place window on upper half of screen taking 2/3 space"
      echo "  SHIFT-B - place window on lower half of screen taking 1/3 space"
      echo
      echo "  TL - place window to left/upper  part of screen"
      echo "  TR - place window to left/lower  part of screen"
      echo "  BL - place window to right/upper part of screen"
      echo "  BR - place window to right/lower part of screen"
      echo
      echo "  SHIFT-TL - use left/upper  part with 2/3 of H. and 2/3 V. space"
      echo "  SHIFT-TR - use left/lower  part with 2/3 of H. and 1/3 V. space"
      echo "  SHIFT-BL - use right/upper part with 1/3 of H. and 2/3 V. space"
      echo "  SHIFT-BR - use right/lower part with 1/3 of H. and 1/3 V. space"
      echo
      echo "  C - center window covering about 2/3 of screen"
      echo "  F - make current window go fullscreen"
      echo "  Q - remove fullscreen property from window"
      echo
      exit 1
      ;;
  esac

}

snap ${1}
