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
# DESKTOP ANY APPLICATION PAUSE
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

__usage() {
  echo "usage: ${0##*/} OPTION [ARGUMENT]"
  echo
  echo "OPTIONS:"
  echo "  -a  -  Do pause/resume active window."
  echo "  -A  -  Do pause/resume active window and minimize it."
  echo "  -s  -  Do pause/resume interactively selected window."
  echo "  -S  -  Do pause/resume interactively selected window and minimize it."
  echo "  -p  -  Do pause/resume specified PID."
  echo "  -l  -  Do list paused processes/windows."
  echo "  -L  -  Do list paused processes/windows with PIDs."
  echo
  echo "ARGUMENT:"
  echo "  PID for '-p' option."
  echo
  exit 1
}

case ${1} in
  (-a)
    PID=$( xdotool getactivewindow getwindowpid )
    ;;

  (-A)
    PID=$( xdotool getactivewindow getwindowpid )
    MIN=1
    ;;

  (-p)
    if ! expr ${2} + 1 1> /dev/null 2> /dev/null
    then
      echo "NOPE: PID must be a number."
      exit 1
    else
      if [ ${2} -lt 1 -o ${2} -gt 99999 ]
      then
        echo "NOPE: PID must be in the 1-99999 number range."
        exit 1
      fi
    fi

    if ! ps -o pid ${2} 1> /dev/null 2> /dev/null
    then
      echo "NOPE: PID '${2}' does not exists."
      exit 1
    fi

    PID=${2}
    ;;

  (-s)
    PID=$( xprop | awk '/^_NET_WM_PID/ {print $3}' )
    ;;

  (-S)
    PID=$( xprop | awk '/^_NET_WM_PID/ {print $3}' )
    MIN=1
    ;;

  (-l)
    ps -U ${USER} -o state,comm \
      | grep '^T' \
      | grep -v 'Ts+' \
      | sort -u \
      | awk '{print $2}'
    exit 0
    ;;

  (-L)
    ps -U ${USER} -o state,pid,comm \
      | grep '^T' \
      | grep -v 'Ts+' \
      | awk '{print substr($0, index($0, $2))}'
    exit 0
    ;;

  (*)
    __usage
    ;;

esac

if [ "${PID}" = "" ]
then
  echo "NOPE: Could not get PID of the window."
  exit 1
fi

STATE=$( ps -o state ${PID} | sed 1d )

case ${STATE} in
  (I*|S*|R*) SIGNAL=STOP ;;
  (T*)       SIGNAL=CONT ;;
  (*)
    zenity --info --text "NOPE: not supported '${STATE}' process state." \
      1> /dev/null 2> /dev/null
    echo "NOPE: not supported '${STATE}' process state."
    exit 1
    ;;
esac

if [ "${MIN}" = "1" -a "${SIGNAL}" = "STOP" ]
then
  for WINDOW in $( xdotool search --pid ${PID} )
  do
    xdotool windowminimize ${WINDOW}
    echo "INFO: xdotool windowminimize ${WINDOW} (PID: ${PID})"
  done
fi
kill -${SIGNAL} ${PID}
echo "INFO: kill -${SIGNAL} ${PID}"
pgrep -P ${PID} \
  | while read I
    do
      if [ "${MIN}" = "1" -a "${SIGNAL}" = "STOP" ]
      then
        for WINDOW in $( xdotool search --pid ${I} )
        do
          xdotool windowminimize ${WINDOW}
          echo "INFO: xdotool windowminimize ${WINDOW} (PID: ${I})"
        done
      fi
      kill -${SIGNAL} ${I}
      echo "INFO: kill -${SIGNAL} ${I}"
    done

echo '1' >> ~/scripts/stats/${0##*/}
