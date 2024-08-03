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
# Find duplicated files in directory tree
# comparing by file NAME/SIZE/MD5 checksum
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

export LC_ALL=C
export LANG=C

__usage() {
  echo "usage: ${0##*/} OPTION DIRECTORY"
  echo "  OPTIONS: -n   check by name (fast)"
  echo "           -s   check by size (medium)"
  echo "           -m   check by md5  (slow)"
  echo "           -N   same as '-n' but with delete instructions printed"
  echo "           -S   same as '-s' but with delete instructions printed"
  echo "           -M   same as '-m' but with delete instructions printed"
  echo "  EXAMPLE: ${0##*/} -s /mnt"
  exit 1
  }

__prefix() {
  case $( id -u ) in
    (0) PREFIX="rm -rf" ;;
    (*) case $( uname ) in
          (SunOS) PREFIX="pfexec rm -rf" ;;
          (*)     PREFIX="doas rm -rf"   ;;
        esac
        ;;
  esac
  }

__crossplatform() {
  case $( uname ) in
    (FreeBSD)
      MD5="md5 -r"
      STAT="stat -f %z"
      ;;
    (Linux)
      MD5="md5sum"
      STAT="stat -c %s"
      ;;
    (SunOS)
      echo "INFO: supported systems: FreeBSD Linux"
      echo
      echo "Porting to Solaris/OpenSolaris"
      echo "  -- provide values for MD5/STAT in '${0##*/}:__crossplatform()'"
      echo "  -- use digest(1) instead for md5 sum calculation"
      echo "       $ digest -a md5 file"
      echo "  -- pfexec(1) is already used in '${0##*/}:__prefix()'"
      echo
      exit 1
    (*)
      echo "INFO: supported systems: FreeBSD Linux"
      exit 1
      ;;
  esac
  }

__md5() {
  __crossplatform
  :> ${DUPLICATES_FILE}
  DATA=$( find "${1}" -type f -exec ${MD5} {} ';' | sort -n )
  echo "${DATA}" \
    | awk '{print $1}' \
    | uniq -c \
    | while read LINE
      do
        COUNT=$( echo ${LINE} | awk '{print $1}' )
        [ ${COUNT} -eq 1 ] && continue
        SUM=$( echo ${LINE} | awk '{print $2}' )
        echo "${DATA}" | grep ${SUM} >> ${DUPLICATES_FILE}
      done

  echo "${DATA}" \
    | awk '{print $1}' \
    | sort -n \
    | uniq -c \
    | while read LINE
      do
        COUNT=$( echo ${LINE} | awk '{print $1}' )
        [ ${COUNT} -eq 1 ] && continue
        SUM=$( echo ${LINE} | awk '{print $2}' )
        echo "count: ${COUNT} | md5: ${SUM}"
        grep ${SUM} ${DUPLICATES_FILE} \
          | cut -d ' ' -f 2-10000 2> /dev/null \
          | while read LINE
            do
              if [ -n "${PREFIX}" ]
              then
                echo "  ${PREFIX} \"${LINE}\""
              else
                echo "  ${LINE}"
              fi
            done
        echo
      done
  rm -rf ${DUPLICATES_FILE}
  }

__size() {
  __crossplatform
  find "${1}" -type f -exec ${STAT} {} ';' \
    | sort -n \
    | uniq -c \
    | while read LINE
      do
        COUNT=$( echo ${LINE} | awk '{print $1}' )
        [ ${COUNT} -eq 1 ] && continue
        SIZE=$( echo ${LINE} | awk '{print $2}' )
        SIZE_KB=$( echo ${SIZE} / 1024 | bc )
        echo "count: ${COUNT} | size: ${SIZE_KB}KB (${SIZE} bytes)"
        if [ -n "${PREFIX}" ]
        then
          find ${1} -type f -size ${SIZE}c -exec echo "  ${PREFIX} \"{}\"" ';'
        else
          find ${1} -type f -size ${SIZE}c -exec echo "  {}" ';'
        fi
        echo
      done
  }

__file() {
  __crossplatform
  find "${1}" -type f \
    | xargs -n 1 basename 2> /dev/null \
    | tr '[A-Z]' '[a-z]' \
    | sort -n \
    | uniq -c \
    | sort -n -r \
    | while read LINE
      do
        COUNT=$( echo ${LINE} | awk '{print $1}' )
        [ ${COUNT} -eq 1 ] && break
        FILE=$( echo ${LINE} | cut -d ' ' -f 2-10000 2> /dev/null )
        echo "count: ${COUNT} | file: ${FILE}"
        FILE=$( echo ${FILE} | sed -e s/'\['/'\\\['/g -e s/'\]'/'\\\]'/g )
        if [ -n "${PREFIX}" ]
        then
          find ${1} -iname "${FILE}" -exec echo "  ${PREFIX} \"{}\"" ';'
        else
          find ${1} -iname "${FILE}" -exec echo "  {}" ';'
        fi
        echo
      done
  }

# main()

[ ${#} -ne 2  ] && __usage
[ ! -d "${2}" ] && __usage

DUPLICATES_FILE="/tmp/${0##*/}_DUPLICATES_FILE.tmp"

case ${1} in
  (-n)           __file "${2}" ;;
  (-m)           __md5  "${2}" ;;
  (-s)           __size "${2}" ;;
  (-N) __prefix; __file "${2}" ;;
  (-M) __prefix; __md5  "${2}" ;;
  (-S) __prefix; __size "${2}" ;;
  (*)  __usage ;;
esac
