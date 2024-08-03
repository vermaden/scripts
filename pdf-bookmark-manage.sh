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
# manage PDF bookmarks
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

# DEBUG
# echo "1: ${1}"
# echo "2: ${2}"
# echo "3: ${3}"

__usage() {
  NAME="${0##*/}"
  echo
  echo "usage: ${NAME} OPTION PDF_FILE BOOKMARK_FILE"
  echo
  echo "  OPTIONS"
  echo "    dump       dump bookmark PDF data"
  echo "    update   update bookmark PDF data"
  echo "    remove   remove bookmark PDF data"
  echo
  echo "  EXAMPLES"
  echo "    ${NAME} dump   REPORT.pdf REPORT.pdf.bookmarks"
  echo "    ${NAME} update REPORT.pdf REPORT.pdf.bookmarks.modified"
  echo "    ${NAME} remove REPORT.pdf"
  echo
  exit 1
}

if [ ${#} -ne 2 -a ${#} -ne 3 ]
then
  __usage
fi

if [ ! -f "${2}" ]
then
  echo
  echo "ERROR: file '${2}' does not exists"
  __usage
fi

for BIN in pdftk
do
  if ! /usr/bin/which ${BIN} 1> /dev/null 2> /dev/null
  then
    echo "ERROR: Binary '${BIN}' not in \$\{PATH\}."
    exit 1
  fi
done

case ${1} in
  (dump)
    if [ -f "${3}" ]
    then
      RANDOM=` expr $( ( ps aux ; time date +"%S" ; w ; last ) 2>&1 | cksum | awk '{print $1}' ) % 32768 `
      echo
      echo "WARNING: a file '${3}' already exists"
      echo "INFO: using new '${3}.${RANDOM}' name instead"
      echo
      BOOKMARK="${3}.${RANDOM}"
    else
      BOOKMARK="${3}"
    fi

    pdftk "${2}" dump_data > "${BOOKMARK}" 2>&1 | grep -v '_JAVA_OPTIONS'

    echo
    echo "INFO: file '${BOOKMARK}' created"
    echo
    ;;

  (update)
    if [ ! -f "${3}" ]
    then
      echo
      echo "ERROR: file '${3}' does not exists"
      __usage
    fi

    pdftk "${2}" update_info "${3}" output "${2}".BOOKMARKS_NEW.pdf 2>&1 | grep -v '_JAVA_OPTIONS'

    echo
    echo "INFO: file '${2}.BOOKMARKS_NEW.pdf' created"
    echo
    ;;

  (remove)
    if [ -f "${2}.BOOKMARKS_REMOVED.pdf" ]
    then
      RANDOM=` expr $( ( ps aux ; time date +"%S" ; w ; last ) 2>&1 | cksum | awk '{print $1}' ) % 32768 `
      echo
      echo "WARNING: a file '${2}.BOOKMARKS_REMOVED.pdf' already exists"
      echo "INFO: using new '${2}.BOOKMARKS_REMOVED.${RANDOM}.pdf' name instead"
      echo
      OUTPUT="${2}.BOOKMARKS_REMOVED.${RANDOM}.pdf"
    else
      OUTPUT="${2}.BOOKMARKS_REMOVED.pdf"
    fi

     pdftk A="${2}" cat A1-end output "${OUTPUT}" 2>&1 | grep -v '_JAVA_OPTIONS'

     echo
     echo "INFO: file '${OUTPUT}' created"
     echo
     ;;

  (*)
    __usage
    ;;

esac
