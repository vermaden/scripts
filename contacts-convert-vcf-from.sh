#! /bin/sh

# Copyright (c) 2018-2020 Slawomir Wojciech Wojtczak (vermaden)
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
# CONTACTS CONVERT FROM VCF FILE
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

__usage() {
  cat << __EOF
usage: ${0##*/} TYPE FILE
  TYPE: -c | --csv
        -p | --plain
        -t | --text

__EOF
  exit 1
}

if [ ${#} -ne 2 ]
then
  __usage
fi

if [ ! -e "${2}" ]
then
  echo "NOPE: file '${2}' does not exists"
  echo
  __usage
  exit 1
fi

# TYPE
case "${1}" in
  (-c|--csv)
    SEPARATOR=","
    echo 'NAME,PHONE,IM,MAIL,NOTES'
    ;;
  (-p|--plain|-t|--text)
    SEPARATOR=" "
    echo 'NAME PHONE IM MAIL NOTES'
    echo '=============================================  ===================================================  ================  ======================================================  ====='
    ;;
  (*)
    __usage
    ;;
esac

( cat "${2}"; echo ) \
  | sed -e s/'\r'//g \
  | while read LINE
    do

      case "${LINE}" in
        (VERSION:*)
          # IGNORE 'VERSION'
          :
          ;;

        (BEGIN*)
          :
          ;;

        (N:*)
          :
          ;;

        (FN*)
          vNAME=$( echo "${LINE}" | awk -F ':' '{print $2}' | tr -d ';' | tr ' ' '-' )
          ;;

        (EMAIL*)
          vMAIL=$( echo "${LINE}" | awk -F ':' '{print $2}' | tr '[:upper:]' '[:lower:]' )
          if [ -z ${vMAILS} ]
          then
            vMAILS="${vMAIL}"
          else
            vMAILS="${vMAILS};${vMAIL}"
          fi
          ;;

        (NOTE*)
          vNOTE=$( echo "${LINE}" | tr -d '|' | tr ' ' ';' | awk -F ':' '{print $2}' )
          if [ -z ${vNOTES} ]
          then
            vNOTES="${vNOTE}"
          else
            vNOTES="${vNOTES};${vNOTE}"
          fi
          ;;

        (ORG*)
          vNOTE=$( echo "${LINE}" | tr -d '|' | tr ' ' ';' | awk -F ':' '{print $2}' )
          if [ -z ${vNOTES} ]
          then
            vNOTES="${vNOTE}"
          else
            vNOTES="${vNOTES};${vNOTE}"
          fi
          ;;

        (X-QQ*)
          vIM=$( echo "${LINE}" | grep -o -E ":.*$" | sed 's/^.//' | tr '[:upper:]' '[:lower:]' )
          ;;

        (TEL*)
        # vTEL=$( echo "${LINE}" | awk -F ':' '{print $2}' | tr -d ' ' | tr -d '-' | tr -d '+[]()' )
          vTEL=$( echo "${LINE}" | awk -F ':' '{print $2=="tel"?$3:$2}' | tr -d ' ' | tr -d '-' | tr -d '[]()' | sed 's/^00/+/' )
          if [ -z ${vTELS} ]
          then
            vTELS="${vTEL}"
          else
            vTELS="${vTELS};${vTEL}"
          fi
          ;;

        (END*)
          # CONTACT NAME
          if [ ${vNAME} ]
          then
            echo -n "${vNAME}"
            vNAME=""
          else
            continue
          fi

          echo -n "${SEPARATOR}"

          # PHONE NUMBERS
          if [ ${vTELS} ]
          then
            echo -n "${vTELS}"
            vTEL=""
            vTELS=""
          else
            echo -n "-"
          fi

          # INSTANT MESSAGING
          echo -n "${SEPARATOR}"

          if [ "${vIM}" ]
          then
            echo -n "${vIM}"
            vIM=""
          else
            echo -n "-"
          fi

          echo -n "${SEPARATOR}"

          # EMAILS
          if [ ${vMAILS} ]
          then
            echo -n "${vMAILS}"
            vMAIL=""
            vMAILS=""
          else
            echo -n "-"
          fi

          echo -n "${SEPARATOR}"

          # NOTES (vNOTES)
          if [ ${vNOTES} ]
          then
            echo -n "${vNOTES}"
            vNOTES=""
          else
            echo -n "-"
          fi

          echo -n "${SEPARATOR}"

          # NOTES (vNOTE)
          if [ ${vNOTE} ]
          then
            echo -n "${vNOTE}"
            vNOTE=""
          else
            echo -n "-"
          fi

          echo
          ;;

      esac
    done | sort -n | uniq
