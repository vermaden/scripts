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
# openbox(1) RECENT FILES OPENED
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

LC_ALL=C
MAX=20
COUNT=0
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
echo " <openbox_pipe_menu>"

[ -f ~/.local/share/recently-used.xbel ] && SOURCE=~/.local/share/recently-used.xbel
[ -f ~/.recently-used.xbel ]             && SOURCE=~/.recently-used.xbel

[ -z ${SOURCE} ] && {
  echo "<separator label=\"ERROR: can not find 'recently-used.xbel' file\" />"
  echo "</openbox_pipe_menu>"
  exit 1
}

tail -r ${SOURCE} \
  | grep -E "(href|exec)" \
  | while read I
    do
      case $(( ${COUNT} % 2 )) in
        (0) CMD=$( echo "${I}" | grep -o -E "&apos;.*&apos;" | sed -e s/'&apos;'//g | cut -d % -f 1 | sed 's/[ ]*$//') ;;
        (1) echo "${I}" | grep href 1> /dev/null 2> /dev/null || continue
            FILE=$( echo "${I}" | tr ' ' '\n' | grep href | cut -d \" -f 2 | sed -e s/%22/\'/g -e s/%3C/\</g -e s/%3E/\>/g -e s/%20/\ /g -e s/'file:\/\/'//g )
            echo "  <item label=\"$( echo ${FILE} | sed -e 's,.*/,,' -e s/_/__/g ) ($( echo ${CMD} | sed -e s/_/__/g ))\">"
            echo "    <action name=\"Execute\">"
            echo "      <command>${CMD} '${FILE}'</command>"
            echo "    </action>"
            echo "  </item>"
            ;;
      esac
      COUNT=$(( ${COUNT} + 1 ))
      [ ${COUNT} -lt $(( 2 * ${MAX} )) ] || break
    done
echo "  <separator />"
echo "  <item label=\"clear\">"
echo "    <action name=\"Execute\">"
echo "      <command>rm -f ~/.recently-used.xbel</command>"
echo "    </action>"
echo "  </item>"
echo "</openbox_pipe_menu>"

exit 0

# FIND recently-used.xbel
if [ ${XDG_DATA_HOME} ] && [ -r "${XDG_DATA_HOME}/recently-used.xbel" ]
then
  FILE="${XDG_DATA_HOME}/recently-used.xbel"
elif [ -r "${HOME}/.local/share/recently-used.xbel" ]
then
  FILE="${HOME}/.local/share/recently-used.xbel"
elif [ -r "${HOME}/.recently-used.xbel" ]
then
  FILE="${HOME}/.recently-used.xbel"
else
  echo "ER: cannot find a readable 'recently-used.xbel' file" 1>&2
  exit 1
fi
