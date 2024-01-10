#! /bin/sh

# Copyright (c) 2022 Slawomir Wojciech Wojtczak (vermaden)
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
# automatic sound output switch
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

SUDO_WHICH=0
SUDO=0
DOAS_WHICH=0
DOAS=1
ROOT=0

# CHECK doas(8) WITH which(1)
if which doas 1> /dev/null 2> /dev/null
then
  DOAS_WHICH=1
else
  DOAS_WHICH=0
fi

# CHECK sudo(8) WITH which(1)
if which sudo 1> /dev/null 2> /dev/null
then
  SUDO_WHICH=1
else
  SUDO_WHICH=0
fi

# CHECK USER WITH whoami(1)
if [ "$( whoami )" = "root" ]
then
  ROOT=1
fi

# CHOOSE ONE FROM doas(8) AND sudo(8)
if [ ${DOAS_WHICH} -eq 1 -o ${SUDO_WHICH} -eq 1 ]
then
  if [   ${DOAS} -eq 0 -a ${SUDO} -eq 1 -a ${SUDO_WHICH} -eq 1 ]
  then
    CMD=sudo
  elif [ ${DOAS} -eq 1 -a ${SUDO} -eq 0 -a ${DOAS_WHICH} -eq 1 ]
  then
    CMD=doas
  elif [ ${DOAS} -eq 1 -a ${SUDO} -eq 1 -a ${DOAS_WHICH} -eq 1 ]
  then
    CMD=doas
  fi
elif [ ${ROOT} -eq 1 ]
then
  CMD=''
else
  echo "NOPE: This script needs 'doas' or 'sudo' to work properly."
  exit 1
fi

unset SUDO_WHICH
unset DOAS_WHICH
unset ROOT

DISPLAY=:0
USERNAME=vermaden
DEFAULT=0

case ${1} in
  (attach)
    # WORKAROUND FOR RACE CONDITION
    sleep 0.2
    SNDSTAT=$( cat /dev/sndstat )
    DEV=$(    echo "${SNDSTAT}" | awk '/^pcm/' | tail -1 | tr '>' ']' | tr '<' '[' )
    LATEST=$( echo "${SNDSTAT}" | awk '/^pcm/ {print $1}' | tail -1 )
    LATEST_NUMBER=$( echo "${LATEST}" | tr -c -d '\n0-9' )
    UNIT=$( echo ${LATEST} | tr -c -d '[0-9]' )
    ${CMD} sysctl hw.snd.default_unit=${UNIT}             &
    pactl set-default-sink oss_output.dsp${LATEST_NUMBER} &
    ;;

  (detach)
    ${CMD} sysctl hw.snd.default_unit=${DEFAULT}    &
    pactl set-default-sink oss_output.dsp${DEFAULT} &
    DEV=$( grep pcm${DEFAULT} /dev/sndstat | tr '>' ']' | tr '<' '[' | sed s/default//g )
    ;;

  (*)
    exit 0
    ;;

esac

UNIT=$( sysctl -n hw.snd.default_unit )
PIDS=$( ${CMD} ps ax -U ${USERNAME} -o pid \
          | while read PID
            do
              ${CMD} procstat files ${PID} 2> /dev/null
            done \
              | awk '/\/dev\/dsp/ {print "-", $1, $2}' \
              | sort -u \
              | grep -v pulseaudio )

# CHECK HOW MANY PROCESSES NEED TO BE RESTARTED
if [ "${PIDS}" = "" ]
then
  # NO PROCESSES TO SWITCH TO NEW AUDIO SOURCE
  env DISPLAY=${DISPLAY} \
    zenity \
      --info \
      --no-wrap \
      --text "New USB audio output attached.\n\nNew audio output:\n\n<b>- ${DEV}</b>" &
else
  # SOME PROCESSES NEED TO SWITCH TO NEW AUDIO SOURCE
  if env DISPLAY=${DISPLAY} \
       zenity \
         --question \
         --default-cancel \
         --no-wrap \
         --text "New USB audio output attached.\n\nProcesses below needs to be killed/restarted to have new audio output.\n\nThey are in <b>PID</b> <b>PROCESSNAME</b> format.\n\n<b>${PIDS}</b>\n\nNew audio output:\n\n<b>- ${DEV}</b>\n\nWould You like to <b>kill(1)</b> these processes now?"
  then
    PIDS_KILL=$( echo "${PIDS}" | awk '{print $2}' | tr '\n' ' ' )
    kill -9 ${PIDS_KILL}
  fi

fi
