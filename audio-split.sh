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
# SPLIT AUDIO FILES INTO PARTS
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

__usage() {
  echo "usage:"
  echo "  $( basename ${0} ) LENGTH FILE"
  echo
  echo "options:"
  echo "  LENGTH - how long the parts should be"
  echo "  FILE   - file you want to split in parts of LENGTH duration"
  echo
  echo "example:"
  echo "  $( basename ${0} ) 10 Some-Long-Audiobook.mp3"
  echo
  echo "  Above command will split that FILE into 10 minutes parts."
  echo
  exit 1
}

case ${#} in

  (2)
    # CHECK IF LENGTH IS NATURAL NUMBER
    REGEX_NUMBER=$( echo ${1} | grep -E -o "[0-9]+" )
    if [ "${1}" != "${REGEX_NUMBER}" ]
    then
      echo "NOPE: the TBW must be natural number of TERABYTES"
      exit 1
    fi

    # CHECK IF FILE EXISTS
    if [ ! -e "${2}" ]
    then
      echo "NOPE: file '${2}' does not exists"
      exit 1
    fi

    # METADATA
    LENGTH=${1}
    FILE=${2}
    DURATION=$( ffprobe -i "${FILE}" -show_entries format=duration -v quiet -of csv='p=0' -sexagesimal 2> /dev/null )
    DURATION_ROUNDED=$( echo ${DURATION} | awk -F '.' '{print $1}' )
    DURATION_SECONDS=$( date -j -u -f "%Y-%m-%d %H:%M:%S" "1970-01-01 ${DURATION_ROUNDED}" +"%s" )
    DURATION_MINUTES=$(( ${DURATION_SECONDS} / 60 ))

    # CHECK IF LENGTH <= DURATION
    TEST=$( echo "${LENGTH} <= ${DURATION_MINUTES}" | bc -l 2> /dev/null )
    if [ "${TEST}" != "1" ]
    then
      echo "NOPE: the LENGTH is larger then the DURATION of entire FILE"
      exit 1
    fi

    # DO WORK HERE
    EXTENSION="${FILE##*.}"
    NAME=$( echo "${FILE}" | sed 's/\..*$//g' )
    mkdir -p "${NAME}"
    COUNT=1
    for I in $( seq 0 ${LENGTH} ${DURATION_MINUTES} )
    do
      FF_BEGIN=$(( 60 * ${I} ))
      FF_END=$(( ${FF_BEGIN} + ( 60 * ${LENGTH} ) ))
      ffmpeg                \
        -y                  \
        -hide_banner        \
        -nostdin            \
        -loglevel error     \
        -i "${FILE}"        \
        -ss "${FF_BEGIN}"   \
        -to "${FF_END}"     \
        -acodec copy        \
        "${NAME}/${NAME} - $( printf "%003d" ${COUNT} ).${EXTENSION}"
      echo "${NAME}/${NAME} - $( printf "%003d" ${COUNT} ).${EXTENSION}"
      COUNT=$(( ${COUNT} + 1 ))
    done
    ;;

  (*)
    __usage
    ;;

esac

