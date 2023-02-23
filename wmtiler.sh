#! /usr/bin/env bash

# (c) 2015 Emanuele Tironi
# (c) 2023 Slawomir Wojciech Wojtczak (vermaden)
# All rights reserved.

# FORK OF: https://github.com/Ema0/arch/blob/master/wmtiler.sh

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
# TILE WM WINDOWS IN X11 SYSTEM
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

# USES wmctrl(1) AND xwininfo(1) TO TILE WINDOWS

# OPTIONS:
# - LEFT_MASTER       (default)
# - RIGHT_MASTER      -r
# - TOP_MASTER        -t
# - BOTTOM_MASTER     -b
# - GRID              -g
# - MAX               -m
# - VERTICAL_SPLIT    -v
# - HORIZONTAL_SPLIT  -h

# NOTE: wmctrl(1) sets properties of window itself i.e. window manager borders and title bars
#       are not taken into account while setting coordinates. For best results set window
#       manager to display all windows undecorated or manually set title bar height here

# TODO:
# - get values of TOP_MARGIN/BOTTOM_MARGIN/LEFT_MARGIN/RIGHT_MARGIN from window manager
# - get MASTER_WIDTH for LEFT_MASTER/RIGHT_MASTER layouts as parameter use default if not provided
# - get MASTER_HEIGHT for TOP_MASTER/BOTTOM_MASTER layouts as parameter use default if not provided
# - get NUMBER_OF_ROWS for GRID as parameter use default if not provided
# - get  TITLE_BAR_HEIGHT from the window manager
# - restructure code to use functions
# - provide mechanisms to increase/decrease MASTER area
# - provide mechanisms to increase/decrease number of windows in MASTER area

# BUGS:
# - if called from key combination :ACTIVE: window may be missing - so results will not be good
# - title bar plays havoc with height of windows

# need to find a way to get these from the window manager
# for openbox(1) check <margins> in the ~/.config/openbox/rc.xml file
TOP_MARGIN=29
BOTTOM_MARGIN=1
LEFT_MARGIN=1
RIGHT_MARGIN=1

# works best if all windows are borderless and this is set to zero
TITLE_BAR_HEIGHT=21

# either set these in file or calculate them from screen properties
MASTER_WIDTH=1344
MASTER_HEIGHT=600

# set number of rows we want for grid mode
NUMBER_OF_ROWS=2

# looks nice :)
USELESS_GAPS=1

# see what user wants to do
case ${1} in
  (-g) MODE=GRID             ;;
  (-m) MODE=MAX              ;;
  (-v) MODE=VERTICAL_SPLIT   ;;
  (-h) MODE=HORIZONTAL_SPLIT ;;
  (-t) MODE=TOP_MASTER       ;;
  (-b) MODE=BOTTOM_MASTER    ;;
  (-r) MODE=RIGHT_MASTER     ;;
  (*)  MODE=LEFT_MASTER      ;;
esac

# get desktop parameters
XWININFO_ROOT=$( xwininfo -root )
HEIGHT=$( echo "${XWININFO_ROOT}" | grep 'Height:' | awk '{print $2}' )
WIDTH=$(  echo "${XWININFO_ROOT}" | grep 'Width:'  | awk '{print $2}' )

# get current desktop
CURR_DESK=$( wmctrl -d | grep '* DG:'| awk '{print $1}' )

# get total number of windows
WMCTRL_LX=$( wmctrl -lx )
TOTAL_WINDOWS=$( echo "${WMCTRL_LX}" | wc -l )

# assume that there are no windows in current desktop
WINDOWS_IN_DESK=0

i=1
while [ ${i} -le ${TOTAL_WINDOWS} ]
do
  CURR_LINE=$( echo "${WMCTRL_LX}" | head -n ${i} | tail -n 1 )
  WIN_DESK=$( echo ${CURR_LINE} | awk '{print $2}' )
  if [ ${WIN_DESK} -eq ${CURR_DESK} ]
  then
    # save various window properties as supplied by wmctrl(1)
    # uncomment rest if necessary || include more if necessary
      WIN_XID[${WINDOWS_IN_DESK}]=$(    echo ${CURR_LINE} | awk '{print $1}' )
    # WIN_XOFF[${WINDOWS_IN_DESK}]=$(   echo ${CURR_LINE} | awk '{print $2}' )
    # WIN_YOFF[${WINDOWS_IN_DESK}]=$(   echo ${CURR_LINE} | awk '{print $3}' )
    # WIN_WIDTH[${WINDOWS_IN_DESK}]=$(  echo ${CURR_LINE} | awk '{print $4}' )
    # WIN_HEIGHT[${WINDOWS_IN_DESK}]=$( echo ${CURR_LINE} | awk '{print $5}' )

    # see if window is "IsViewable" or "IsUnMapped" (minimized)
    MAP_STATE=$( xwininfo -id ${WIN_XID[${WINDOWS_IN_DESK}]} | grep "Map State:" | awk '{print $3}' )
    # we do not  want minimized windows to be considered while allocating space
    if [ "${MAP_STATE}" == "IsViewable" ]
    then
      WINDOWS_IN_DESK=$(( ${WINDOWS_IN_DESK} + 1 ))
    fi
  fi
  i=$((${i}+1))
done

# get xid of active window
ACTIVE_WIN=$( xprop -root | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}' )

# set selected layout
case ${MODE} in

  (LEFT_MASTER)
    # define properties of master area
    X=${LEFT_MARGIN}
    Y=${TOP_MARGIN}
    # set width to default MASTER_WIDTH
    W=${MASTER_WIDTH}
    H=$(( ${HEIGHT} - ${TOP_MARGIN} - ${BOTTOM_MARGIN} - ${TITLE_BAR_HEIGHT} - ${USELESS_GAPS} ))
    # set active window to "master "area
    wmctrl -r :ACTIVE: -e "0,${X},${Y},${W},${H}"
    # now that master window has been set all further windows would have to start from here
    X=$((${MASTER_WIDTH}+${USELESS_GAPS}))
    # get whatever width is left
    W=$((${WIDTH} - ${MASTER_WIDTH} - ${USELESS_GAPS}))
    # height would be equally shared by rest of windows
    H=$(( ${H} / (${WINDOWS_IN_DESK} - 1) - ${TITLE_BAR_HEIGHT} - ${USELESS_GAPS} ))
    i=0
    while [ "${i}" -le "${WINDOWS_IN_DESK}" ]
    do
      # avoid setting attributes of active window again
      if [[ "${WIN_XID[${i}]}" -ne "${ACTIVE_WIN}" ]]
      then
        # set attributes
        wmctrl -i -r ${WIN_XID[${i}]} -e "0,${X},${Y},${W},${H}"
        # set Y co-ordinate for next window
        Y=$((${Y} + ${H} + ${TITLE_BAR_HEIGHT} + ${USELESS_GAPS} ))
      fi
      # preselect next window
      i=$(( ${i} + 1 ))
    done
    ;;

  (RIGHT_MASTER)
    # define properties of master area
    X=${LEFT_MARGIN}
    Y=${TOP_MARGIN}
    # get whatever width is left
    W=$(( ${WIDTH} - ${MASTER_WIDTH} - ${USELESS_GAPS} ))
    # height would be equally shared by non master windows
    H=$(( ( ${HEIGHT} - ${TOP_MARGIN} - ${BOTTOM_MARGIN} ) / ( ${WINDOWS_IN_DESK} - 1 ) - ${TITLE_BAR_HEIGHT} - ${USELESS_GAPS} ))
    i=0
    while [ "${i}" -le "${WINDOWS_IN_DESK}" ]
    do
      # avoid setting attributes of active window
      if [[ "${WIN_XID[${i}]}" -ne "${ACTIVE_WIN}" ]]
      then
        # set attributes
        wmctrl -i -r ${WIN_XID[${i}]} -e "0,${X},${Y},${W},${H}"
        # set Y co-ordinate for next window
        Y=$(( ${Y} + ${H} + ${TITLE_BAR_HEIGHT} + ${USELESS_GAPS} ))
      fi
      # preselect next window
      i=$(( ${i} + 1 ))
    done
    # set co-ordinates for MASTER_WINDOW
    X=$(( ${W} + ${USELESS_GAPS} ))
    Y=${TOP_MARGIN}
    W=${MASTER_WIDTH}
    H=$(( ${HEIGHT} - ${TOP_MARGIN} - ${BOTTOM_MARGIN} - ${TITLE_BAR_HEIGHT} - ${USELESS_GAPS} ))
    # set active window to master area
    wmctrl -r :ACTIVE: -e "0,${X},${Y},${W},${H}"
    ;;

  (TOP_MASTER)
    # define properties of master area
    X=${LEFT_MARGIN}
    Y=${TOP_MARGIN}
    # set width taking into acount margins
    W=$(( ${WIDTH} - ${LEFT_MARGIN} - ${RIGHT_MARGIN} ))
    H=${MASTER_HEIGHT}
    # set active window to master area
    wmctrl -r :ACTIVE: -e "0,${X},${Y},${W},${H}"
    # set y co-ordinate
    Y=$(( ${Y} + ${H} + ${USELESS_GAPS} + ${TITLE_BAR_HEIGHT} ))
    # distribute width amon remaining windows
    W=$(( ${W} / ( ${WINDOWS_IN_DESK} - 1 ) ))
    # set new height
    H=$(( ${HEIGHT} - ${MASTER_HEIGHT} - ${TOP_MARGIN} - ${BOTTOM_MARGIN} - ${TITLE_BAR_HEIGHT} - ${USELESS_GAPS} ))
    i=0
    while [ "${i}" -le "${WINDOWS_IN_DESK}" ]
    do
      # avoid setting attributes of active window again
      if [[ "${WIN_XID[${i}]}" -ne "${ACTIVE_WIN}" ]]
      then
        # set attributes
        wmctrl -i -r ${WIN_XID[${i}]} -e "0,${X},${Y},${W},${H}"
        # set X co-ordinate for next window
        X=$(( ${X} + ${W} + ${USELESS_GAPS} ))
      fi
      # preselect next window
      i=$(( ${i} + 1 ))
    done
    ;;

  (BOTTOM_MASTER)
    # define properties of master area
    X=${LEFT_MARGIN}
    Y=${TOP_MARGIN}
    # distribute width among non master windows
    W=$(( ( ${WIDTH} - ${LEFT_MARGIN} - ${RIGHT_MARGIN} ) / ( ${WINDOWS_IN_DESK} - 1 ) ))
    # set new height
    H=$(( ${HEIGHT} - ${MASTER_HEIGHT} - ${TOP_MARGIN} - ${BOTTOM_MARGIN} - ${TITLE_BAR_HEIGHT} - ${USELESS_GAPS} ))
    i=0
    while [ "${i}" -le "${WINDOWS_IN_DESK}" ]
    do
      # avoid setting attributes of active window again
      if [[ "${WIN_XID[${i}]}" -ne "${ACTIVE_WIN}" ]]
      then
        # set attributes
        wmctrl -i -r ${WIN_XID[${i}]} -e "0,${X},${Y},${W},${H}"
        # set X co-ordinate for next window
        X=$(( ${X} + ${W} + ${USELESS_GAPS} ))
      fi
      # preselect next window
      i=$(( ${i} + 1 ))
     done
     # set co-ordinates
     X=${LEFT_MARGIN}
     Y=$(( ${Y} + ${H} + ${USELESS_GAPS} + ${TITLE_BAR_HEIGHT} ))
     W=$(( ${WIDTH} - ${LEFT_MARGIN} - ${RIGHT_MARGIN} ))
     H=${MASTER_HEIGHT}
     # set active window to master area
     wmctrl -r :ACTIVE: -e "0,${X},${Y},${W},${H}"
     ;;

  (GRID)
    # find number of windows in top row and in each subsequent row except for bottom row
    NORMAL_ROW_WINDOWS=$(( ${WINDOWS_IN_DESK} / ${NUMBER_OF_ROWS} ))
    # bottom row ould have as many windows as top row and any left over
    BOTTOM_ROW_WINDOWS=$(( ${NORMAL_ROW_WINDOWS} + ${WINDOWS_IN_DESK} % ${NUMBER_OF_ROWS} ))
    WINDOWS_NOT_IN_BOTTOM_ROW=$(( ${WINDOWS_IN_DESK} - ${BOTTOM_ROW_WINDOWS} ))
    # set co-ordinates for top row
    X=${LEFT_MARGIN}
    Y=${TOP_MARGIN}
    # height of each window would remain same regardless of which row it is in
    H=$(( ( ${HEIGHT} - ${TOP_MARGIN} - ${BOTTOM_MARGIN} ) / ${NUMBER_OF_ROWS} - ${TITLE_BAR_HEIGHT} ))
    # find width of each window in top row - this would be same
    # for each row except for bottom row which may contain more windows
    NORMAL_ROW_WIDTH=$(( ( ( ${WIDTH} - ${LEFT_MARGIN} - ${RIGHT_MARGIN} ) / ${NORMAL_ROW_WINDOWS} ) - ${USELESS_GAPS} * ${NORMAL_ROW_WINDOWS} ))
    BOTTOM_ROW_WIDTH=$(( ( ( ${WIDTH} - ${LEFT_MARGIN} - ${RIGHT_MARGIN} ) / ${BOTTOM_ROW_WINDOWS} ) - ${USELESS_GAPS} * ${NORMAL_ROW_WINDOWS} ))
    # start counting from zero
    i=0
    # we havent processed any windows yet
    CURRENT_ROW_WINDOWS=0
    # we will be processing 1st row
    CURRENT_ROW=1
    while  [ "${i}" -le "${WINDOWS_IN_DESK}" ]
    do
      if [[ "${CURRENT_ROW}" -lt "${NUMBER_OF_ROWS}" ]]
      then
        if [[ "${CURRENT_ROW_WINDOWS}" -eq "${NORMAL_ROW_WINDOWS}" ]]
        then
          CURRENT_ROW=$(( ${CURRENT_ROW} + 1 ))
          if [[ "${CURRENT_ROW}" -eq "${NUMBER_OF_ROWS}" ]]
          then
            X=${LEFT_MARGIN}
            Y=$(( ${Y} + ${H} + ${TITLE_BAR_HEIGHT} + ${USELESS_GAPS} ))
            W=${BOTTOM_ROW_WIDTH}
          else
            CURRENT_ROW_WINDOWS=0
          fi
        fi
        if [[ "${CURRENT_ROW_WINDOWS}" -eq "0" ]]
        then
          X=${LEFT_MARGIN}
          W=${NORMAL_ROW_WIDTH}
          if [[ "${CURRENT_ROW}" -ne "1" ]]
          then
            Y=$(( ${Y} + ${H} + ${TITLE_BAR_HEIGHT} + ${USELESS_GAPS} ))
          fi
        fi
      fi
      wmctrl -i -r ${WIN_XID[${i}]} -e "0,${X},${Y},${W},${H}"
      X=$(( ${X} + ${W} + ${USELESS_GAPS} ))
      CURRENT_ROW_WINDOWS=$(( ${CURRENT_ROW_WINDOWS} + 1 ))
      i=$(( ${i} + 1 ))
    done
    ;;

  (MAX)
    X=${LEFT_MARGIN}
    Y=${TOP_MARGIN}
    H=$(( ${HEIGHT} - ${TOP_MARGIN} - ${BOTTOM_MARGIN} ))
    W=$(( ${WIDTH} - ${LEFT_MARGIN} - ${RIGHT_MARGIN} ))
    i=0
    while [ "${i}" -le "${WINDOWS_IN_DESK}" ]
    do
      # avoid setting attributes of active window
      if [[ "${WIN_XID[${i}]}" -ne "${ACTIVE_WIN}" ]]
      then
        # set attributes
        wmctrl -i -r ${WIN_XID[${i}]} -e "0,${X},${Y},${W},${H}"
      fi
      # preselect next window
      i=$(( ${i} + 1 ))
    done
    # now that all windows have been set set master on top
    wmctrl -r :ACTIVE: -e "0,${X},${Y},${W},${H}"
    ;;

  (VERTICAL_SPLIT)
    X=${LEFT_MARGIN}
    Y=${TOP_MARGIN}
    H=$(( ${HEIGHT} - ${TOP_MARGIN} - ${BOTTOM_MARGIN} ))
    W=$(( ( ${WIDTH} - ${LEFT_MARGIN} - ${RIGHT_MARGIN} ) / ${WINDOWS_IN_DESK} - ${USELESS_GAPS} ))
    i=0
    while [ "${i}" -le "${WINDOWS_IN_DESK}" ]
    do
      wmctrl -i -r ${WIN_XID[${i}]} -e "0,${X},${Y},${W},${H}"
      # preselect next window
      X=$(( ${X} + ${W} + ${USELESS_GAPS} ))
      i=$(( ${i} + 1 ))
    done
    ;;

  (HORIZONTAL_SPLIT)
    X=${LEFT_MARGIN}
    Y=${TOP_MARGIN}
    H=$(( ( ${HEIGHT} - ${TOP_MARGIN} - ${BOTTOM_MARGIN} ) / ${WINDOWS_IN_DESK} - ${TITLE_BAR_HEIGHT} - ${USELESS_GAPS} ))
    W=$(( ${WIDTH} - ${LEFT_MARGIN} - ${RIGHT_MARGIN} ))
    i=0
    while [ "${i}" -le "${WINDOWS_IN_DESK}" ]
    do
      wmctrl -i -r ${WIN_XID[${i}]} -e "0,${X},${Y},${W},${H}"
      # preselect next window
      Y=$(( ${Y} + ${H} + ${TITLE_BAR_HEIGHT} + ${USELESS_GAPS} ))
      i=$(( ${i} + 1 ))
    done
    ;;

esac
