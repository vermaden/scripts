#! /bin/sh

# Copyright (c) 2020 Slawomir Wojciech Wojtczak (vermaden)
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
# FETCH DNS ANTISPAM FOR UNBOUND
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com



# SETTINGS
FILE=/var/unbound/conf.d/blacklist.conf
TYPE=always_nxdomain
TEMP=/tmp/unbound
ECHO=0



# CLEAN
[ "${ECHO}" != "0" ] && echo "rm: remove temp '${TEMP}' temp dir"
rm -rf   ${TEMP}



# TEMP DIR
[ "${ECHO}" != "0" ] && echo "mkdir: create '${TEMP}' temp dir"
mkdir -p ${TEMP}



# FETCH
[ "${ECHO}" != "0" ] && echo "fetch: ${TEMP}/unbound-oznu"
fetch -q -a -r -o ${TEMP}/unbound-oznu \
  https://raw.githubusercontent.com/oznu/dns-zone-blacklist/master/unbound/unbound-nxdomain.blacklist

[ "${ECHO}" != "0" ] && echo "fetch: ${TEMP}/hosts-winhelp"
fetch -q -a -r -o ${TEMP}/hosts-winhelp \
  https://winhelp2002.mvps.org/hosts.txt

[ "${ECHO}" != "0" ] && echo "fetch: ${TEMP}/hosts-steven-black"
fetch -q -a -r -o ${TEMP}/hosts-steven-black \
  https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts

[ "${ECHO}" != "0" ] && echo "fetch: ${TEMP}/hosts-adaway"
fetch -q -a -r -o ${TEMP}/hosts-adaway \
  http://adaway.org/hosts.txt

[ "${ECHO}" != "0" ] && echo "fetch: ${TEMP}/hosts-someone-cares"
fetch -q -a -r -o ${TEMP}/hosts-someone-cares \
  http://someonewhocares.org/hosts/hosts

[ "${ECHO}" != "0" ] && echo "fetch: ${TEMP}/hosts-malware"
fetch -q -a -r -o ${TEMP}/hosts-malware \
  http://www.malwaredomainlist.com/hostslist/hosts.txt



# GENERATE
[ "${ECHO}" != "0" ] && echo "echo: add '${FILE}' header"
echo 'server:' > ${FILE}

[ "${ECHO}" != "0" ] && echo "echo: add '${FILE}' rules"
(
  # LIST UNBOUND SOURCES
  awk -F '"' '{print $2}' ${TEMP}/unbound-*

  # LIST HOSTS SOURCES
  cat ${TEMP}/hosts-* \
  | grep -v '^#' \
  | grep -v '^$' \
  | awk '{print $2}'

) \
  | sed -e s/$'\r'//g \
  | sort -u \
  | sed 1,9d \
  | while read I
    do
      echo "local-zone: \"${I}\" ${TYPE}"
    done >> ${FILE}



# CLEAN
[ "${ECHO}" != "0" ] && echo "rm: remove temp '${TEMP}' temp dir"
rm -r -f ${TEMP}



# UNSET
unset FILE
unset TYPE
unset TEMP
unset ECHO


