#! /bin/sh

# Copyright (c) 2026 Slawomir Wojciech Wojtczak (vermaden)
# All rights reserved.
#
# THIS SOFTWARE USES FREEBSD LICENSE (ALSO KNOWN AS 2-CLAUSE BSD LICENSE)
# https://freebsd.org/copyright/freebsd-license.html
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
# freebsd-update(8) SCREENSAVER
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

# SETTINGS
  VEROLD="14.4-RELEASE"
  VERNEW="15.0-RELEASE"

__random() {
  ( time ps aux ; date +"%S" ; w ) 2>&1 \
    | cksum \
    | awk '{print substr($0, 0, 6)}'
}

__rand_sleep() { # 1=MAXIMUM_MAJOR
  local RANDOM=$( __random )
  if [ ${1} ]
  then
    sleep $(( ${RANDOM} % ${1} )).$(( ${RANDOM} % 9 ))
  else
    sleep 0.$(( ${RANDOM} % 2 ))
  fi

  # DEBUG
  # sleep 0.1
}

echo -n "Looking up update.FreeBSD.org mirrors... "
__rand_sleep
echo " 3 mirrors found."

echo -n "Fetching public key from update2.freebsd.org... "
__rand_sleep
echo "done."

echo -n "Fetching metadata signature for ${VEROLD} from update2.freebsd.org... "
__rand_sleep
echo "done."

echo -n "Fetching metadata index... "
__rand_sleep
echo "done."

echo -n "Fetching 2 metadata files... "
__rand_sleep 5
echo "done."

# WAIT HERE
__rand_sleep 5

echo -n "Inspecting system... "
__rand_sleep 5
echo "done."

echo

echo "The following components of FreeBSD seem to be installed:"
echo "kernel/generic src/src world/base world/doc"

echo

echo "The following components of FreeBSD do not seem to be installed:"
echo "kernel/generic-dbg world/base-dbg world/lib32 world/lib32-dbg"

echo

echo -n "Does this look reasonable (y/n)? "
sleep 1
__rand_sleep 5
echo "y"

# WAIT HERE
__rand_sleep 3

echo

echo -n "Fetching metadata signature for ${VERNEW} from update2.freebsd.org... "
__rand_sleep 3
echo "done."

echo -n "Fetching metadata index... "
__rand_sleep 3
echo "done."

echo -n "Fetching 1 metadata patches. "
__rand_sleep 5
echo "done."

# WAIT HERE
__rand_sleep 5

echo -n "Applying metadata patches... "
__rand_sleep
echo "done."

echo -n "Fetching 1 metadata files... "
__rand_sleep
echo "done."

echo -n "Inspecting system... "
__rand_sleep 5
echo "done."

echo -n "Fetching files from ${VEROLD} for merging... "
__rand_sleep
echo "done."

echo -n "Preparing to download files... "
__rand_sleep
echo "done."

MAX=$(( 20000 + $( __random ) % 30000 ))
COUNT=0

# DEBUG
# MAX=33

echo -n "Fetching ${MAX} patches."
while __rand_sleep
do
  COUNT=$(( ${COUNT} + 2 ))
  if [ $(( ${COUNT} % 10 )) -eq 0 ]
  then
    echo -n "${COUNT}"
  else
    echo -n "."
  fi
  if [ ${COUNT} -gt ${MAX} ]
  then
    echo " done."
    break
  fi
done

echo -n "Applying patches... "
__rand_sleep 3
echo "done."

MAX=$(( 20000 + $( __random ) % 30000 ))
COUNT=0

# DEBUG
# MAX=33

echo -n "Fetching ${MAX} patches."
while __rand_sleep
do
  COUNT=$(( ${COUNT} + 2 ))
  if [ $(( ${COUNT} % 10 )) -eq 0 ]
  then
    echo -n "${COUNT}"
  else
    echo -n "."
  fi
  if [ ${COUNT} -gt ${MAX} ]
  then
    echo " done."
    break
  fi
done

echo -n "Attempting to automatically merge changes in files... "
__rand_sleep 1
echo "done."

echo

echo "The following file could not be merged automatically: /etc/group"
echo "Press Enter to edit this file in vi and resolve the conflicts"
echo "manually..."

read
