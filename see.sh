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
        xchm "${@}" 1> /dev/null 2> /dev/null &
        ;;

      # HTM
      # HTML
      ( [Hh][Tt][Mm][Ll] \
      | [Hh][Tt][Mm]     )
        case "${@}" in
          (/*) midori -p          "${@}" 1> /dev/null 2> /dev/null & ;;
          (*)  midori -p $( pwd )/"${@}" 1> /dev/null 2> /dev/null & ;;
        esac
        # firefox -new-tab "${@}" &
        ;;

      # ODT
      ( [Oo][Dd][Tt] )
        env QT_FONT_DPI=80 libreoffice "${@}" 1> /dev/null 2> /dev/null &
	;;

      # MP3
      # M4A
      # MP4A
      ( [Mm][Pp][3] \
      | [Mm][4][Aa] \
      | [Mm][Pp][4][Aa] )
        deadbeef --queue "${@}" 1> /dev/null 2> /dev/null &
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
      # BMP
      ( [Jj][Pp][Ee]     \
      | [Jj][Pp][Gg]     \
      | [Jj][Pp][Ee][Gg] \
      | [Pp][Nn][Gg]     \
      | [Gg][Ii][Ff]     \
      | [Tt][Ii][Ff][Ff] \
      | [Tt][Ii][Ff]     \
      | [Xx][Pp][Mm]     \
      | [Xx][Bb][Mm]     \
      | [Bb][Mm][Pp]     \
      | [Ss][Vv][Gg]     )
        viewnior "${@}" 1> /dev/null 2> /dev/null &
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
        # evince "${@}" 1> /dev/null 2> /dev/null &
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
      # SRT
      # PL
      # PUB
      # VCF
      ( [Tt][Xx][Tt] \
      | [Ss][Rr][Tt] \
      | [Pp][Ll]     \
      | [pP][uU][bB] \
      | [Vv][Cc][Ff] )
        leafpad "${@}" 1> /dev/null 2> /dev/null &
        ;;

      # XML
      ( [Xx][Mm][Ll] )
        geany --new-instance "${@}" 1> /dev/null 2> /dev/null &
        ;;

      # SH
      # AWK
      ( [Ss][Hh] )
        geany "${@}" 1> /dev/null 2> /dev/null &
        ;;

      # CSV
      # GNUMERIC
      ( [Cc][Ss][Vv]                     \
      | [Gg][Nn][Uu][Mm][Ee][Rr][Ii][Cc] )
        gnumeric "${@}" 1> /dev/null 2> /dev/null &
        ;;

      # ODS
      # RTF
      ( [Oo][Dd][Ss] \
      | [Rr][Tt][Ff] )
        env QT_FONT_DPI=80 libreoffice --nologo "${@}" 1> /dev/null 2> /dev/null &
        ;;

      # XLSX
      # XLS
      ( [Xx][Ll][Ss]     \
      | [Xx][Ll][Ss][Xx] )
        env QT_FONT_DPI=80 libreoffice --nologo "${@}" 1> /dev/null 2> /dev/null &
        ;;

      # DOCX
      # DOC
      ( [Dd][Oo][Cc]     \
      | [Dd][Oo][Cc][Xx] )
        env QT_FONT_DPI=80 libreoffice --nologo "${@}" 1> /dev/null 2> /dev/null &
        ;;

      # PPTX
      # PPT
      ( [Pp][Pp][Tt]     \
      | [Pp][Pp][Tt][Xx] )
        env QT_FONT_DPI=80 libreoffice --nologo "${@}" 1> /dev/null 2> /dev/null &
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
      # TS
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
      | [Vv][Oo][Bb]     \
      | [Tt][Ss]         \
      | [Mm][Pp][Gg]     )
        mpv "${@}" 1> /dev/null 2> /dev/null &
        ;;

      # GZ
      # BZ2
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
      | [Bb][Zz][2]      \
      | [Rr][Aa][Rr]     \
      | [Ll][Zz][Mm][Aa] \
      | [7][Zz]          \
      | [Tt][Gg][Zz]     )
        engrampa "${@}" 1> /dev/null 2> /dev/null &
        ;;

      # XML
      # NFO
      ( [Xx][Mm][Ll] \
      | [Nn][Ff][Oo] )
        leafpad "${@}" 1> /dev/null 2> /dev/null &
        ;;

      # SWF
      ( [Ss][Ww][Ff] )
        wine ~/win32/bin/flashplayer_32_sa.exe "${@}" 1> /dev/null 2> /dev/null &
        ;;

      # EXE
      ( [Ee][Xx][Ee] )
        wine "${@}" 1> /dev/null 2> /dev/null &
        ;;

      (*)
        TYPE=$( file "${@}" | awk -F':' '{print $2}' | awk -F',' '{print $1}' | tr -d ' ' )

        case ${TYPE} in

          (ASCIItext)
            leafpad "${@}" 1> /dev/null 2> /dev/null &
            ;;

          (POSIXshellscript)
            geany "${@}" 1> /dev/null 2> /dev/null &
            ;;

          (awkscript)
            geany "${@}" 1> /dev/null 2> /dev/null &
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
      "${0}" "${FILE}" 1> /dev/null 2> /dev/null &
    done
    ;;

esac

# TODO
#
# (magnet:.*)                                  tremc "$1"
# (.*.torrent)                                 tremc "$1"
# (https://(?:www\.)?youtube.com/watch\?v=.*)  mpv "$1"
# https://youtu.be/(.+)                        mpv "ytdl://$1"
# (https?://?.*)                               w3m -o confirm_q=False "$1"
# (git://.*\.git)                              git clone --recursive "$1"
