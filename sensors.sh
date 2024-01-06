#! /bin/sh

# Copyright (c) 2022-2023 Slawomir Wojciech Wojtczak (vermaden)
# Copyright (c) 2022 Trix Farrar
# All rights reserved.
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
# SIMPLE SENSORS INFORMATION
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

__usage() {
  local NAME=${0##*/}
  echo "USAGE:"
  echo "  ${NAME} (without any arguments)"
  echo
  echo "NOTES:"
  echo "  load these modules to get all the temperature data:"
  echo "    - amdtemp.ko"
  echo "    - coretemp.ko"
  echo
  echo "  install 'smartmontools' package for disks temperatures:"
  echo "    # pkg install smartmontools"
  echo
  echo "  you need to execute as 'root' to get disks temperatures"
  echo "    # ${NAME}"
  echo "    % doas ${NAME}"
  echo "    $ sudo ${NAME}"
  echo
  exit 1
}

# DISPLAY HELP
if [ "${1}" = "-h"    -o \
     "${1}" = "help"  -o \
     "${1}" = "-help" -o \
     "${1}" = "--help" ]
then
  __usage
fi

# DISPLAY VERSION
if [ "${1}" = "--version" -o \
     "${1}" =  "-version" -o \
     "${1}" =   "version" ]
then
  cat << VERSION
                                                   __ ____ __
                                                  / //    \\\\ \\
   _____ _____   ____  _____ ____   _  ___ _____ / //  /  / \\ \\
  /  __//  _  \ /    \/  __//    \ / \/ _//  __// / \     \ / /
  \__  \\\\  ___//  /  /\__  \\\\  \  \\\\   /  \__  \\\\ \ /  /  // /
 /_____/ \___//__/__//_____/ \____/ \__\ /_____/ \_\\\\____//_/

sensors 0.3 2023/09/15

VERSION
  exit 0
fi

# GET sysctl(8) OUTPUT ONLY ONCE
SYSCTL=$( sysctl dev hw.acpi 2> /dev/null )

# HEADER: BATTERY/AC/TIME/FAN/SPEED
echo
printf "%38s\n" 'BATTERY/AC/TIME/FAN/SPEED '
printf "%38s\n" '------------------------------------ '

# DISPLAY RELEVANT INFORMATION
echo "${SYSCTL}"                   \
  | grep -e dev.cpu.0.freq:        \
         -e hw.acpi.cpu.cx_lowest  \
         -e dev.cpu.0.cx_supported \
         -e dev.cpu.0.cx_usage:    \
         -e hw.acpi.acline         \
         -e hw.acpi.battery.life   \
         -e hw.acpi.battery.time   \
         -e \.fan                  \
  | sort -n                        \
  | while read MIB VALUE1 VALUE2
    do
      printf "%38s %s" ${MIB} ${VALUE1}
      printf " %s" ${VALUE2}
      printf "\n"
    done

# CHECK IF power(8) IS RUNNING
POWERD=0
if pgrep -q -x -S "powerd" 1> /dev/null 2> /dev/null
then
  printf "%38s %s\n" "powerd(8):" "running"
  POWERD=1
fi

# CHECK IF powerxx(8) IS RUNNING
POWERDXX=0
if pgrep -q -x -S "powerd\+\+" 1> /dev/null 2> /dev/null
then
  printf "%38s %s\n" "powerdxx(8):" "running"
  POWERDXX=1
fi

# DISPLAY powerd(8)/powerdxx(8) STATUS
if [ ${POWERD} -eq 0 -a ${POWERDXX} -eq 0 ]
then
  printf "%38s %s\n" "powerd(8)/powerdxx(8):" "disabled"
  unset POWERD
  unset POWERDXX
fi



# HEADER: SYSTEM/TEMPERATURES
echo
printf "%38s\n" 'SYSTEM/TEMPERATURES '
printf "%38s\n" '------------------------------------ '

# DISPLAY RELEVANT INFORMATION
if sysctl -n dev.cpu.0.coretemp.tjmax 1> /dev/null 2> /dev/null
then
  TEMP_MAX_CPU=1
fi
if sysctl -n hw.acpi.thermal.tz0._CRT 1> /dev/null 2> /dev/null
then
  TEMP_MAX_ACPI=1
fi
echo "${SYSCTL}"                            \
  | grep -e temperature                     \
  | grep -v 'critical temperature detected' \
  | sort -n -t . -k 3                       \
  | while read MIB VALUE
    do
      case ${MIB} in
        # USE 3 FIELDS FOR dev.cpu.* MIBS
        (dev.cpu.*)
          PREFIX=$( echo ${MIB} | awk -F '.' '{print $1 "\\." $2 "\\." $3 "\\."}' )
          if [ "${TEMP_MAX_CPU}" = "1" ]
          then
            MAX=$( echo "${SYSCTL}"        \
                     | grep "${PREFIX}"    \
                     | grep coretemp.tjmax \
                     | awk '{print $NF}' )
            printf "%38s %s (max: %s)\n" ${MIB} ${VALUE} ${MAX}
          else
            printf "%38s %s\n" ${MIB} ${VALUE}
          fi
          unset PREFIX
          unset MAX
          ;;
        # USE 4 FIELDS FOR hw.acpi.thermal.* MIBS
        (hw.acpi.thermal.*)
          PREFIX=$( echo ${MIB} | awk -F '.' '{print $1 "\\." $2 "\\." $3 "\\." $4 "\\."}' )
          if [ "${TEMP_MAX_ACPI}" = "1" ]
          then
            MAX=$( echo "${SYSCTL}"     \
                     | grep "${PREFIX}" \
                     | grep _CRT:       \
                     | awk '{print $NF}' )
            printf "%38s %s (max: %s)\n" ${MIB} ${VALUE} ${MAX}
          else
            printf "%38s %s\n" ${MIB} ${VALUE}
          fi
          unset PREFIX
          unset MAX
          ;;
        # JUST DISPLAY WITHOUT PARSING FOR OTHER MIBS
        (*)
          printf "%38s %s\n" ${MIB} ${VALUE}
          ;;
      esac
    done
unset TEMP_MAX_CPU
unset TEMP_MAX_ACPI



# HEADER: DISKS/TEMPERATURES
echo
printf "%38s\n" 'DISKS/TEMPERATURES '
printf "%38s\n" '------------------------------------ '

# WE NEED root PERMISSIONS FOR smartctl(8) COMMAND
if [ $( whoami ) != "root" ]
then
  echo "   Run '${0##*/}' as 'root' to display disks temperatures."
  echo
  exit 0
fi

# CHECK IF smartctl() IS AVAILABLE
if ! which smartctl 1> /dev/null 2> /dev/null
then
  echo "   Install 'sysutils/smartmontools' package to display disks temperatures."
  echo
  exit 0
fi

# DISPLAY TEMPERATURE FOR EACH DISK
for I in $( sysctl -n kern.disks | tr ' ' '\n' | sort -n )
do
  case ${I} in
    # IGNORE cd(4) DEVICES
    (cd*)
      continue
      ;;

    # THE nvd(4)/nda(4)/nvme(4) DEVICES NEED SPECIAL HANDLING
    (nvd*|nda*)
      I=$( echo ${I} | sed -e 's/nvd/nvme/g' -e 's/nda/nvme/g' )
      smartctl -a /dev/${I}    \
        | grep -e Temperature: \
        | sed -E 's|\(.*\)||g' \
        | tr -d ':'            \
        | awk -v DISK=${I}     \
            '{MIB="smart." DISK "." tolower($1) ":"; printf("%38s %s.0C\n", MIB, $(NF-1))}'
      ;;
    # SATA/ATA/SCSI/USB DISKS
    (*)
      smartctl -a /dev/${I}    \
        | grep -e Temperature_ \
        | sed -E 's|\(.*\)||g' \
        | awk -v DISK=${I} \
            '{MIB="smart." DISK "." tolower($2) ":"; printf("%38s %s.0C\n", MIB, $NF)}'
      ;;
  esac
done
echo
