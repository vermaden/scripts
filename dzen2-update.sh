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
# DZEN2 UPDATE
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

# SETTINGS
CLA='^fg(#aaaaaa)'
CVA='^fg(#eeeeee)'
CDE='^fg(#dd0000)'

# CUSTOM MATH FUNCTION
__math() {
  local SCALE=1
  local RESULT=$( echo "scale=${SCALE}; ${@}" | bc -l )
  if echo ${RESULT} | grep --color -q '^\.'
  then
    echo -n 0
  fi
  echo ${RESULT}
  unset SCALE
  unset RESULT
}

# GATHER DATA
  SMP=$(     sysctl -n kern.smp.cpus )
  SMP=$((    ${SMP} * 100 ))
  PS=$(      ps ax -o %cpu,rss,command -c )
  CPU=$(     echo "${PS}" | awk -v SMP=${SMP} '/\ idle$/ {printf("%.1f%%",SMP-$1)}' )
# LOAD=$(    sysctl -n vm.loadavg | awk '{print $2}' )
  DATE=$(    date +%Y/%m/%d/%a/%H:%M )
  FREQ=$(    sysctl -n dev.cpu.0.freq )
# TEMP=$(    sysctl -n hw.acpi.thermal.tz0.temperature )
  TEMP=$(    sysctl -n dev.cpu.0.temperature )
  MEM=$(( $( sysctl -n vm.stats.vm.v_inactive_count )
        + $( sysctl -n vm.stats.vm.v_free_count )
        + $( sysctl -n vm.stats.vm.v_cache_count ) ))
  MEM=$(     __math ${MEM} \* 4 / 1024 / 1024 )
  IF_IP=$(   ~/scripts/__conky_if_ip.sh )
  IF_GW=$(   ~/scripts/__conky_if_gw.sh )
  IF_DNS=$(  ~/scripts/__conky_if_dns.sh )
  IF_PING=$( ~/scripts/__conky_if_ping.sh dzen2 )
  VOL=$(     mixer -s vol | awk -F ':' '{printf("%s",$2)}' )
  FS=$(      zfs list -H -d 0 -o name,avail | awk '{printf("%s/%s ",$1,$2)}' )
  BAT=$(     ~/scripts/__conky_battery_separate.sh dzen2 )
  TOP=$(     echo "${PS}" | bsdgrep -v -E '(COMMAND|idle)$' | sort -r -n \
               | head -3 | awk '{printf("%s/%d%%/%.1fGB ",$3,$1,$2/1024/1024)}' )

# PRESENT DATA
echo -n        " ${CLA}date: ${CVA}${DATE} "
echo -n "${CDE}| ${CLA}sys: ${CVA}${FREQ}MHz/${TEMP}/${CPU}/${MEM}GB "
echo -n "${CDE}| ${CLA}ip: ${CVA}${IF_IP}"      # NO SPACE AT THE END
echo -n "${CDE}| ${CLA}gw: ${CVA}${IF_GW} "
echo -n "${CDE}| ${CLA}dns: ${CVA}${IF_DNS} "
echo -n "${CDE}| ${CLA}ping: ${CVA}${IF_PING} "
echo -n "${CDE}| ${CLA}vol: ${CVA}${VOL} "
echo -n "${CDE}| ${CLA}fs: ${CVA}${FS}"         # NO SPACE AT THE END
echo -n "${CDE}| ${CLA}bat: ${CVA}${BAT} "
echo -n "${CDE}| ${CLA}top: ${CVA}${TOP}"       # NO SPACE AT THE END
echo

echo '1' >> ~/scripts/stats/${0##*/}
