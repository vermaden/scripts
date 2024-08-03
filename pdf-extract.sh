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
# extract pages from PDF file with pdftk
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

if [ ${#} -eq 0 ]
then
  ME="${0##*/}"
  echo "usage: ${ME} FILE OPTIONS"
  echo
  echo "examples: ${ME} file.pdf 13"
  echo "examples: ${ME} file.pdf 1-12 14-end"
  echo "examples: ${ME} file.pdf 1-40"
  echo
  exit 1
fi

for BIN in pdftk
do
  if ! /usr/bin/which ${BIN} 1> /dev/null 2> /dev/null
  then
    echo "ERROR: Binary '${BIN}' not in \$\{PATH\}."
    exit 1
  fi
done

if [ ! -f "${1}" ]
then
  echo "ERROR: No such file or directory '${1}'."
  exit 1
fi

FILE="${1}"
shift
NAME="${FILE}.EXTRACT.$( echo ${@} | tr ' ' '-' ).pdf"
# echo file: ${FILE}
# echo args: ${@}

pdftk "${FILE}" cat ${@} output "${NAME}" 2>&1 | grep -v '_JAVA_OPTIONS'

# ALTERNATIVE gs(1) COMMAND
# $ gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dSAFER \
#      -dFirstPage=22 -dLastPage=36 \
#      -sOutputFile=outfile_p22-p36.pdf 100p-inputfile.pdf

if [ ${?} -eq 0 ]
then
  echo "INFO: File '${NAME}' generated."
fi
