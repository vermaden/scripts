#! /bin/sh

# Copyright (c) 2017-2021 Slawomir Wojciech Wojtczak (vermaden)
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
# UNIVERSAL FILES OPENER FOR X11
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

__usage() {
  echo "usage: ${0##*/} FILE [FILE]"
  exit 1
}

if [ ${#} -eq 0 ]
then
  __usage
fi

case ${#} in

  # ONLY SINGLE FILE IS PASSED - OPEN IT ACCORDING TO ITS EXTENSION
  (1)

    if [ ! -f "${@}" ]
    then
      echo "ERROR: file '${@}' does not exists."
      __usage
    fi

    EXTENSION="${@##*.}"
    EXIT=0

    case "${EXTENSION}" in

      # CHM
      ( [Cc][Hh][Mm] )
        xchm "${@}" &
        ;;

      # HTM
      # HTML
      ( [Hh][Tt][Mm][Ll] \
      | [Hh][Tt][Mm]     )
        firefox -new-tab "${@}" &
        ;;

      # ODT
      ( [Oo][Dd][Tt] )
        env QT_FONT_DPI=80 libreoffice "${@}" &
        ;;

      # MP3
      # M4A
      # MP4A
      ( [Mm][Pp][3] \
      | [Mm][4][Aa] \
      | [Mm][Pp][4][Aa] )
        deadbeef --queue "${@}" &
        ;;

      # MHT
      ( [Mm][Hh][Tt] )
        chrome    "${@}" 1> /dev/null 2> /dev/null &
        ;;

      # JPG
      # JPE
      # JPEG
      # PNG
      # SVG
      # GIF
      # TIF
      # TIFF
      # XPM
      # XBM
      ( [Jj][Pp][Ee]     \
      | [Jj][Pp][Gg]     \
      | [Jj][Pp][Ee][Gg] \
      | [Pp][Nn][Gg]     \
      | [Gg][Ii][Ff]     \
      | [Tt][Ii][Ff][Ff] \
      | [Tt][Ii][Ff]     \
      | [Xx][Pp][Mm]     \
      | [Xx][Bb][Mm]     \
      | [Ss][Vv][Gg]     )
        viewnior "${@}" &
        ;;

      # MOBI
      ( [Mm][Oo][Bb][Ii] )
        sumatra.sh "${@}" 1> /dev/null 2> /dev/null &
        ;;

      # EPUB
      # PDF
      ( [Ee][Pp][Uu][Bb] \
      | [Pp][Dd][Ff]     )
        mupdf.sh "${@}" 1> /dev/null 2> /dev/null &
        # sumatra.sh "${@}" 1> /dev/null 2> /dev/null &
        # evince "${@}"
        ;;

      # DJVU
      # DJV
      ( [Dd][Jj][Vv][Uu] \
      | [Dd][Jj][Vv]     )
        DIRECTORY="${@%/*}"
        FILE="${@##*/}"
        cd "${DIRECTORY}"
        djvu2reader.sh "${@}" 1> /dev/null 2> /dev/null &
        ;;

      # TXT
      # PL
      # PUB
      # VCF
      ( [Tt][Xx][Tt] \
      | [Pp][Ll]     \
      | [pP][uU][bB] \
      | [Vv][Cc][Ff] )
        leafpad "${@}" &
        ;;

      # XML
      ( [Xx][Mm][Ll] )
        geany --new-instance "${@}" &
        ;;

      # SH
      # AWK
      ( [Ss][Hh] )
        geany "${@}" &
        ;;

      # CSV
      # GNUMERIC
      ( [Cc][Ss][Vv]                     \
      | [Gg][Nn][Uu][Mm][Ee][Rr][Ii][Cc] )
        gnumeric "${@}" &
        ;;

      # ODS
      # RTF
      ( [Oo][Dd][Ss] \
      | [Rr][Tt][Ff] )
        env QT_FONT_DPI=80 libreoffice --nologo "${@}" &
        ;;

      # XLSX
      # XLS
      ( [Xx][Ll][Ss]     \
      | [Xx][Ll][Ss][Xx] )
        env QT_FONT_DPI=80 libreoffice --nologo "${@}" &
        ;;

      # DOCX
      # DOC
      ( [Dd][Oo][Cc]     \
      | [Dd][Oo][Cc][Xx] )
        env QT_FONT_DPI=80 libreoffice --nologo "${@}" &
        ;;

      # PPTX
      # PPT
      ( [Pp][Pp][Tt]     \
      | [Pp][Pp][Tt][Xx] )
        env QT_FONT_DPI=80 libreoffice --nologo "${@}" &
        ;;

      # AVI
      # MP4
      # M4V
      # MKV
      # MTS
      # WMV
      # RMVB
      # WEBM
      # OGV
      # MPG
      ( [Aa][Vv][Ii]     \
      | [Mm][pP][4]      \
      | [Mm][4][Vv]      \
      | [Mm][Kk][Vv]     \
      | [Mm][Tt][Ss]     \
      | [Ww][Mm][Vv]     \
      | [Rr][Mm][Vv][Bb] \
      | [Ww][Ee][Bb][Mm] \
      | [Oo][Gg][Vv]     \
      | [Mm][Pp][Gg]     )
        mpv "${@}" 1> /dev/null 2> /dev/null &
        ;;

      # GZ
      # XZ
      # ISO
      # ZIP
      # RAR
      # LZMA
      # 7Z
      # TGZ
      ( [Ii][Ss][Oo]     \
      | [Zz][Ii][Pp]     \
      | [Gg][Zz]         \
      | [Xx][Zz]         \
      | [Rr][Aa][Rr]     \
      | [Ll][Zz][Mm][Aa] \
      | [7][Zz]          \
      | [Tt][Gg][Zz]     )
        engrampa "${@}" &
        ;;

      # XML
      # NFO
      ( [Xx][Mm][Ll] \
      | [Nn][Ff][Oo] )
        leafpad "${@}" &
        ;;

      # SWF
      ( [Ss][Ww][Ff] )
        wine ~/win32/bin/flashplayer_32_sa.exe "${@}" &
        ;;

      (*)
        TYPE=$( file "${@}" | awk -F':' '{print $2}' | awk -F',' '{print $1}' | tr -d ' ' )

        case ${TYPE} in

          (ASCIItext)
            leafpad "${@}" &
            ;;

          (POSIXshellscript)
            geany "${@}" &
            ;;

          (awkscript)
            geany "${@}" &
            ;;

          (*)
            EXIT=1
            ;;

        esac

        if [ ${EXIT} -ne 0 ]
        then
          echo "INFO: extension '${EXTENSION}' not supported"
          echo "INFO: add support for that '${EXTENSION}' at '${0}' file"
          exit 1
        fi
        ;;

    esac
    ;;

  # MORE THEN ONE FILE IS PASSED - OPEN EACH IN SEPARATE PROCESS
  (*)
    for FILE in "${@}"
    do
      "${0}" "${FILE}" &
    done
    ;;

esac

echo '1' 2> /dev/null >> ~/scripts/stats/${0##*/}
