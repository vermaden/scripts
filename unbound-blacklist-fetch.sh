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
ECHO=1



# CLEAN
[ "${ECHO}" != "0" ] && echo "rm: remove temp '${TEMP}' temp dir"
rm -rf   ${TEMP}



# TEMP DIR
[ "${ECHO}" != "0" ] && echo "mkdir: create '${TEMP}' temp dir"
mkdir -p ${TEMP}



# FETCH
[ "${ECHO}" != "0" ] && echo "fetch: ${TEMP}/lists-unbound"
fetch -q -a -r -o - \
  https://raw.githubusercontent.com/oznu/dns-zone-blacklist/master/unbound/unbound-nxdomain.blacklist \
  1> ${TEMP}/lists-unbound 2> /dev/null

[ "${ECHO}" != "0" ] && echo "fetch: ${TEMP}/lists-domains"
fetch -q -a -r -o - \
 'https://pgl.yoyo.org/adservers/serverlist.php?mimetype=plaintext&hostformat=plain'       \
  https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt                               \
  https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt                         \
  https://s3.amazonaws.com/lists.disconnect.me/simple_malware.txt                          \
  https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt                     \
  https://mirror1.malwaredomains.com/files/justdomains                                     \
  https://v.firebog.net/hosts/static/w3kbl.txt                                             \
  https://v.firebog.net/hosts/BillStearns.txt                                              \
  https://raw.githubusercontent.com/matomo-org/referrer-spam-blacklist/master/spammers.txt \
  https://raw.githubusercontent.com/Dawsey21/Lists/master/main-blacklist.txt               \
  1> ${TEMP}/lists-domains 2> /dev/null

[ "${ECHO}" != "0" ] && echo "fetch: ${TEMP}/lists-hosts"
fetch -q -a -r -o - \
  https://someonewhocares.org/hosts/zero/hosts                                            \
  http://winhelp2002.mvps.org/hosts.txt                                                   \
  https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts                        \
  https://adaway.org/hosts.txt                                                            \
  https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts           \
  http://sysctl.org/cameleon/hosts                                                        \
  http://winhelp2002.mvps.org/hosts.txt                                                   \
  https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt \
  https://raw.githubusercontent.com/vokins/yhosts/master/hosts                            \
  1> ${TEMP}/lists-hosts 2> /dev/null



# GENERATE
[ "${ECHO}" != "0" ] && echo "echo: add '${FILE}' header"
echo 'server:' > ${FILE}

[ "${ECHO}" != "0" ] && echo "echo: add '${FILE}' rules"
(
  # LIST UNBOUND SOURCES
  cat ${TEMP}/lists-unbound \
  | grep -v '^#'            \
  | grep -v '^$'            \
  | awk -F '"' '{print $2}'

  # LIST DOMAINS SOURCES
  cat ${TEMP}/lists-domains \
  | grep -v '^#'            \
  | grep -v '^$'            \
  | grep -v '^:'            \
  | grep -v '^;'            \
  | grep -v '^!'            \
  | grep -v '^@'            \
  | grep -v '^\$'           \
  | grep -v localhost       \
  | awk '{print $1}'

  # LIST HOSTS SOURCES
  cat ${TEMP}/lists-hosts     \
  | grep -v '^#'              \
  | grep -v '^$'              \
  | grep -v '127.0.0.1'       \
  | grep -v '0.0.0.0'         \
  | grep -v '255.255.255.255' \
  | grep -v '::'              \
  | awk '{print $2}'

) \
  | sed -e s/$'\r'//g          \
  | tr '[:upper:]' '[:lower:]' \
  | sort -u                    \
  | sed 1,2d                   \
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
