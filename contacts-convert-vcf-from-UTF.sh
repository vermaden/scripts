#! /bin/sh

# Copyright (c) 2018-2024 Slawomir Wojciech Wojtczak (vermaden)
# Copyright (c) 2024 Jon Krom (pe1aqp)
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

__missing_qprint() {
  if [ ${QPRINTWARNING} = 1 ]
  then
    echo "INFO: package 'textproc/qprint' needed for this datafile"
    QPRINTWARNING=0
  fi
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

if [ -x "$( command -v qprint )" ]
then
  MYQPRINT="qprint --decode --noerrcheck"
  QPRINTWARNING=0
else
  MYQPRINT="cat"
  QPRINTWARNING=1
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

# START PARSING THE INPUT FILE
( cat "${2}"; echo ) \
  | ( LC_ALL=C.UTF-8 ${MYQPRINT} ) \
  | sed -e s/'\r'//g \
  | while read LINE
    do

      [ ${QPRINTWARNING} = 1 ] && (echo "${LINE}" | grep -q "QUOTED-PRINTABLE") && __missing_qprint

echo $LINE

      case "${LINE}" in
        (BEGIN*)
          # IGNORE BEGIN
          :
          ;;

        (VERSION:*)
          # IGNORE 'VERSION' - ONLY PROCESS 2.1 OR 4.0 VCARDS
          :
          ;;

        (N:*|N\;*)
          # IGNORE COMPLEX NAME
          :
          ;;

        (FN*)
          # NAME
          vNAME=$( echo "${LINE}" | awk -F ':' '{print $2}' | tr -d ';' | tr ' ' '-' )
          ;;

        (EMAIL*)
          # EMAIL
          vMAIL=$( echo "${LINE}" | awk -F ':' '{print $2}' | tr '[:upper:]' '[:lower:]' )
          if [ -z "${vMAILS}" ]
          then
            vMAILS="${vMAIL}"
          else
            vMAILS="${vMAILS};${vMAIL}"
          fi
          ;;

        (NOTE*|ORG*)
          # NOTES
          vNOTE=$( echo "${LINE}" | tr -d '|' | sed -e "s+;+~;+g" -e "s+ +;+g" | awk -F ':' '{print $2}' )
          if [ -z "${vNOTES}" ]
          then
            vNOTES="${vNOTE}"
          else
            vNOTES="${vNOTES}~;${vNOTE}"
          fi
          ;;

        (X-QQ*)
          # INSTANT MESSAGING
          vIM=$( echo "${LINE}" | grep -o -E ":.*$" | sed 's/^.//' | tr '[:upper:]' '[:lower:]' )
          ;;

        (TEL*)
          # PHONE NUMBER
        # vTEL=$( echo "${LINE}" | awk -F ':' '{print $2=="tel"?$3:$2}' | tr -d ' ' | tr -d '-' | tr -d '[]()' | sed 's/^00/+/' )
          vTEL=$( echo "${LINE}" | awk -F ':' '{if($2=="tel"){print $3}else{print $2}}' | tr -d ' ' | tr -d '-' | tr -d '[]()' | sed 's/^00/+/' )
          if [ -z "${vTELS}" ]
          then
            vTELS="${vTEL}"
          else
            vTELS="${vTELS};${vTEL}"
          fi
          ;;

        (END*)
          # CONTACT NAME
          if [ "${vNAME}" ]
          then
            echo -n "${vNAME}"
            vNAME=""
          else
            continue
          fi

          echo -n "${SEPARATOR}"

          # PHONE NUMBERS
          if [ "${vTELS}" ]
          then
            echo -n "${vTELS}"
            vTEL=""
            vTELS=""
          else
            echo -n "-"
          fi

          echo -n "${SEPARATOR}"

          # INSTANT MESSAGING
          if [ "${vIM}" ]
          then
            echo -n "${vIM}"
            vIM=""
          else
            echo -n "-"
          fi

          echo -n "${SEPARATOR}"

          # EMAILS
          if [ "${vMAILS}" ]
          then
            echo -n "${vMAILS}"
            vMAIL=""
            vMAILS=""
          else
            echo -n "-"
          fi

          echo -n "${SEPARATOR}"

          # NOTES
          if [ "${vNOTES}" ]
          then
            echo -n "${vNOTES}"
            vNOTES=""
          else
            echo -n "-"
          fi

          echo
          ;;

        ("")
          # EAT EMPTY LINES
          :
          ;;

        (\#*)
          # EAT COMMENT LINES
          :
          ;;

        (*)
          echo "NOPE: unknown line: ${LINE}"
          :
          ;;

      esac
    done | sort -u
