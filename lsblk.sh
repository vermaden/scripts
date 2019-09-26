#! /bin/sh

# Copyright (c) 2016-2019 Slawomir Wojciech Wojtczak (vermaden)
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
# REPLACEMENT FOR LINUX lsblk(8)
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

PATH=${PATH}:/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin

__usage() {
  echo "usage: $( basename ${0} ) [DISK]"
  echo
  exit 1
}

# PARSE ALL POSSIBLE BLOCK DEVICES OR JUST SINGLE DEVICE
if [ ${#} -eq 0 ]
then
  # NO ARGUMENTS = ALL DEVICES
  DISKS=$( sysctl -n kern.disks | tr ' ' '\n' )
elif [ ${#} -eq 1 ]
then
  # SINGLE ARGUMENT = SINGLE DISK
  if sysctl -n kern.disks | grep -q "${1}"
  then
    DISKS="${1}"
  else
    echo "NOPE: disk '${1}' does not exist in the system"
    echo
    exit 1
  fi
else
  # SPECIFIED DISK DOES NOT EXIST IN THE SYSTEM
  __usage
fi

# OUTPUT FORMAT
    FORMAT_L0="%-14s %3s:%-3s %4s %-18s %12s %s\n"
  FORMAT_L1="  %-12s %3s:%-3s %4s %-18s %12s %s\n"
FORMAT_L2="    %-10s %3s:%-3s %4s %-18s %12s %s\n"
printf "${FORMAT_L0}" DEVICE MAJ MIN SIZE TYPE LABEL MOUNT

# PARSE DISKS
echo "${DISKS}" \
  | sort -n \
  | while read DEV
    do
      PREFIX=""
      if gpart show ${DEV} 1> /dev/null 2> /dev/null
      then
        # GPART PRESENT
        gpart show ${DEV} 2> /dev/null \
          | tr -d '=>' \
          | while read LINE
            do
              # SKIP EMPTY LINES
              if [ "${LINE}" = "" ]
              then
                continue
              fi
              # ENTIRE DEVICE SIZE
              # VISITED ONLY ONCE WHEN ${PREFIX} IS NOT SET
              if [ "${PREFIX}" = "" ]
              then
                MA_MI=$( ls -l /dev/${DEV} | awk 'END{print $5}' | tr 'x' ':' )
                if [ "${MA_MI}" = "0," ]
                then
                  MA_MI=$( ls -l /dev/${DEV} | awk 'END{print $5"x"$6 }' | tr -d ',' | tr 'x' ':' )
                fi
                SIZE=$( echo "${LINE}" | grep -E -o "\(.*\)" | tr -d '()' )
                if [ "${SIZE}" = "" ]
                then
                  SIZE="-"
                fi
                TYPE=$( echo "${LINE}" | awk 'END{print $4}' )
                case ${TYPE} in
                  (!0)
                    TYPE="<UNSET>"
                    ;;
                  (!12)
                    TYPE="msdosfs"
                    ;;
                esac
                # OUTPUT
                MAJ=$( echo ${MA_MI} | awk -F ':' '{print $1}' )
                MIN=$( echo ${MA_MI} | awk -F ':' '{print $2}' )
                printf "${FORMAT_L0}" ${DEV} ${MAJ} ${MIN} ${SIZE} ${TYPE} - -
                # DETECT PARTITION SCHEMA (GPT/MBR)
                if echo "${LINE}" | grep -q "GPT" 1> /dev/null 2> /dev/null
                then
                  PREFIX=p
                  continue
                fi
                if echo "${LINE}" | grep -q "MBR" 1> /dev/null 2> /dev/null
                then
                  PREFIX=s
                  continue
                fi
                # PARTITION SCHEMA (GPT/MBR) NOT DETECTED
                if [ "${PREFIX}" = "" ]
                then
                  PREFIX=x
                  continue
                fi
              fi

              # PARTITIONS
              # VISITED MANY TIMES EACH TIME FOR EACH PARTITION/SLICE
              if echo "${LINE}" | grep -q -- "- free -" 1> /dev/null 2> /dev/null
              then
                # FREE
                SIZE=$( echo "${LINE}" | grep -E -o "\(.*\)" | tr -d '()' )
                printf "${FORMAT_L1}" "<FREE>" - - ${SIZE} - - -
                continue
              else
                # USED / PART
                SIZE=$( echo "${LINE}" | grep -E -o "\(.*\)" | tr -d '()' )
                NAME=$( echo "${LINE}" | awk 'END{print $3}' )
                TYPE=$( echo "${LINE}" | awk 'END{print $4}' )
                if [ "${TYPE}" = "!0" ]
                then
                  TYPE="<UNSET>"
                fi
                if [ "${DEV}" != "${NAME}" ]
                then
                  NAME="${DEV}${PREFIX}${NAME}"
                fi
                LABEL=$( gpart list ${DEV} 2> /dev/null | grep -A 256 "Name: ${NAME}" | grep -m 1 "label:" | awk 'END{print $2}' )
                if [ "${LABEL}" = "" -o "${LABEL}" = "(null)" ]
                then
                  if which fstyp 1> /dev/null 2> /dev/null
                  then
                    LABEL=$( fstyp -l /dev/${NAME} 2> /dev/null | awk 'END{print $2}' )
                    if [ "${LABEL}" = "" ]
                    then
                      LABEL="-"
                    fi
                  else
                    LABEL="-"
                  fi
                fi
                # MSDOS
                if which fstyp 1> /dev/null 2> /dev/null
                then
                  MOUNT=$( mount | grep /dev/msdosfs/${LABEL} | awk 'END{print $3}' )
                  if [ "${MOUNT}" = "" ]
                  then
                    MOUNT=$( mount | grep /dev/${DEV} | awk 'END{print $3}' )
                    if [ "${MOUNT}" = "" ]
                    then
                      MOUNT="-"
                    else
                      MOUNT_DETECTED=1
                    fi
                  fi
                fi
                # MOUNT POINT DETECT FOR UFS
                if [ "${MOUNT_DETECTED}" != "1" ]
                then
                  MOUNT=$( mount | grep /dev/${NAME} | awk 'END{print $3}' )
                  if [ "${MOUNT}" = "" ]
                  then
                    if [ "${LABEL}" = "!-" ]
                    then
                      MOUNT=$( mount | grep /dev/label/${LABEL} | awk 'END{print $3}' )
                      if [ "${MOUNT}" = "" ]
                      then
                        MOUNT=$( mount | grep /dev/gpt/${LABEL} | awk 'END{print $3}' )
                        if [ "${MOUNT}" = "" ]
                        then
                          MOUNT=$( mount | grep /dev/ufs/${LABEL} | awk 'END{print $3}' )
                          if [ "${MOUNT}" = "" ]
                          then
                            MOUNT="<UNMOUNTED>"
                          fi
                        fi
                      fi
                    else
                      MOUNT="<UNMOUNTED>"
                    fi
                  fi
                fi
                # SWAP ON/OFF DETECTION
                if [ "${TYPE}" = "freebsd-swap" ]
                then
                  if swapinfo | grep -q ${LABEL}
                  then
                    MOUNT="SWAP"
                  elif swapinfo | grep -q ${NAME}
                  then
                    MOUNT="SWAP"
                  fi
                fi
                # BOOT PARTITION
                if [ "${TYPE}" = "freebsd-boot" -o "${TYPE}" = "freebsd" ]
                then
                  MOUNT="-"
                fi
                # ZFS
                if [ "${TYPE}" = "freebsd-zfs" ]
                then
                  MOUNT="<ZFS>"
                fi
                MA_MI=$( ls -l /dev/${NAME} | awk 'END{print $5}' | tr 'x' ':' )
                if [ "${MA_MI}" = "0," ]
                then
                  MA_MI=$( ls -l /dev/${NAME} | awk 'END{print $5"x"$6 }' | tr -d ',' | tr 'x' ':' )
                fi
                # OUTPUT
                MAJ=$( echo ${MA_MI} | awk -F ':' '{print $1}' )
                MIN=$( echo ${MA_MI} | awk -F ':' '{print $2}' )
                printf "${FORMAT_L1}" ${NAME} ${MAJ} ${MIN} ${SIZE} ${TYPE} ${LABEL} ${MOUNT}
                # USED / bsdlabel(8)
                if [ "${TYPE}" = "freebsd" -a "${PREFIX}" != "p" ]
                then
                  if gpart show "${NAME}" 1> /dev/null 2> /dev/null
                  then
                    gpart show "${NAME}" 2> /dev/null \
                      | grep -v '=>' \
                      | while read BSDLINE
                        do
                          # SKIP EMPTY LINES
                          if [ "${BSDLINE}" = "" ]
                          then
                            continue
                          fi
                          # PARTITIONS
                          # VISITED MANY TIMES EACH TIME FOR EACH PARTITION
                          if echo "${BSDLINE}" | grep -q -- "- free -" 1> /dev/null 2> /dev/null
                          then
                            # FREE
                            # DO NOT DISPLAY 16 SECTORS LONG <FREE> IN EACH bsdlabel(8) SCHEMA
                            BEG=$( echo "${BSDLINE}" | awk 'END{print $1}' )
                            END=$( echo "${BSDLINE}" | awk 'END{print $2}' )
                            if [ "$(( ${END} - ${BEG} ))" = "16" ]
                            then
                              continue
                            fi
                            SIZE=$( echo "${BSDLINE}" | grep -E -o "\(.*\)" | tr -d '()' )
                            # OUTPUT
                            printf "${FORMAT_L2}" "<FREE>" - - ${SIZE} - - -
                            continue
                          else
                            # USED
                            SIZE=$( echo "${BSDLINE}" | grep -E -o "\(.*\)" | tr -d '()' )
                            PART=$( echo "${BSDLINE}" | awk 'END{print $3}' )
                            TYPE=$( echo "${BSDLINE}" | awk 'END{print $4}' )
                            if [ "${TYPE}" = "!0" ]
                            then
                              TYPE="<UNSET>"
                            fi
                            # SET APPROPRIATE LETTER FOR EACH PARTITION
                            case ${PART} in
                              (1) BSDPREFIX=a ;;
                              (2) BSDPREFIX=b ;;
                              (3) BSDPREFIX=c ;;
                              (4) BSDPREFIX=d ;;
                              (5) BSDPREFIX=e ;;
                              (6) BSDPREFIX=f ;;
                              (7) BSDPREFIX=g ;;
                              (8) BSDPREFIX=h ;;
                              (9) BSDPREFIX=i ;;
                            esac
                            PART="${NAME}${BSDPREFIX}"
                          fi
                          LABEL=$( glabel list | grep -v -E '(gptid|ufsid)/' | grep -A 256 "Geom name: ${PART}" | grep -m 1 "Name: " | awk 'END{print $3}' )
                          if echo "${LABEL}" | grep -q "label/" 1> /dev/null 2> /dev/null
                          then
                            LABEL=$( echo "${LABEL}" | sed 's|label/||g' | sed 's|gpt/||g' )
                          fi
                          if [ "${LABEL}" = "" -o "${LABEL}" = "(null)" ]
                          then
                            LABEL="-"
                          fi
                          MA_MI=$( ls -l /dev/${PART} | awk 'END{print $5}' | tr 'x' ':' )
                          if [ "${MA_MI}" = "0," ]
                          then
                            MA_MI=$( ls -l /dev/${PART} | awk 'END{print $5"x"$6 }' | tr -d ',' | tr 'x' ':' )
                          fi
                          MOUNT="<UNMOUNTED>"
                          # IF DETECTED PARTITION WAS '!0' THEN IT IS ALREADY SET AS '<UNSET>'
                          # MOUNT POINT DETECT FOR UFS
                          if [ "${TYPE}" = "freebsd-ufs" -o "${TYPE}" = "<UNSET>" ]
                          then
                            MOUNT=$( mount | grep /dev/label/${LABEL} | awk 'END{print $3}' )
                            if [ "${MOUNT}" = "" ]
                            then
                              MOUNT=$( mount | grep /dev/${PART} | awk 'END{print $3}' )
                              if [ "${MOUNT}" = "" ]
                              then
                                MOUNT=$( mount | grep /dev/gpt/${LABEL} | awk 'END{print $3}' )
                                if [ "${MOUNT}" = "" ]
                                then
                                  MOUNT="<UNMOUNTED>"
                                fi
                              fi
                            fi
                          fi
                          # SET PROPER MOUNT FOR bsdlabel(8) PARTITION
                          if [ "${TYPE}" = "freebsd-boot" -o "${TYPE}" = "freebsd" ]
                          then
                            MOUNT="-"
                          fi
                          # SWAP ON/OFF DETECTION
                          if [ "${TYPE}" = "freebsd-swap" ]
                          then
                            if swapinfo | grep -q ${LABEL}
                            then
                              MOUNT="SWAP"
                            elif swapinfo | grep -q ${PART}
                            then
                              MOUNT="SWAP"
                            fi
                          fi
                          # OUTPUT
                          MAJ=$( echo ${MA_MI} | awk -F ':' '{print $1}' )
                          MIN=$( echo ${MA_MI} | awk -F ':' '{print $2}' )
                          printf "${FORMAT_L2}" ${PART} ${MAJ} ${MIN} ${SIZE} ${TYPE} ${LABEL} ${MOUNT}
                        done
                  fi
                fi
              fi
            done
      else
        # GPART ABSENT
        # DMESG INFORMATION CAN BE ABSENT
        SIZE=$( dmesg | grep -E "^${DEV}:.*sectors:" | awk 'END{print $2}' | tr -d 'MB' )
        if [ "${SIZE}" = "" ]
        then
          # IF DMESG INFORMATION IS ABSENT THEN TRY /var/run/dmesg.boot FILE
          if [ -e /var/run/dmesg.boot ]
          then
            SIZE=$( grep -E "^${DEV}:.*sectors:" /var/run/dmesg.boot | awk 'END{print $2}' | tr -d 'MB' )
            # IF SIZE INFO STILL NOT THERE THEN SET AS '-'
            if [ "${SIZE}" = "" ]
            then
              SIZE="-"
            fi
          fi
        fi
        # IF SIZE IS DETECTED THEN FORMAT IT PROPERLY
        if [ "${SIZE}" != "-" ]
        then
          SIZE=$(( ${SIZE} / 1024 ))
          SIZE="${SIZE}G"
        fi
        # USUAL DATA
        MA_MI=$( ls -l /dev/${DEV} | awk 'END{print $5}' | tr 'x' ':' )
        if [ "${MA_MI}" = "0," ]
        then
          MA_MI=$( ls -l /dev/${DEV} | awk 'END{print $5"x"$6 }' | tr -d ',' | tr 'x' ':' )
        fi
        # TRY TO DETECT FS TYPE
        TYPE="-"
        if which fstyp 1> /dev/null 2> /dev/null
        then
          if fstyp /dev/${DEV} 1> /dev/null 2> /dev/null
          then
            TYPE=$( fstyp /dev/${DEV} )
            MOUNT=$( mount | grep /dev/msdosfs/${LABEL} | awk 'END{print $3}' )
            if [ "${MOUNT}" = "" ]
            then
              MOUNT=$( mount | grep /dev/${DEV} | awk 'END{print $3}' )
              if [ "${MOUNT}" = "" ]
              then
                MOUNT="-"
              else
                MOUNT_DETECTED=1
              fi
            fi
          fi
        fi
        # ZFS DETECTION
        if head -c 100000 /dev/${DEV} | strings | grep -q pool_guid 1> /dev/null 2> /dev/null
        then
          TYPE=freebsd-zfs
          # ZFS USUALLY HAVE LOTS OF MOUNT POINTS SO USE '<ZFS>' HERE
          MOUNT="<ZFS>"
        fi
        # IF ITS NOT ZFS THEN FIND PROPER MOUNT POINT
        if [ "${MOUNT}" != "<ZFS>" -a "${MOUNT_DETECTED}" != "1" ]
        then
          MOUNT="-"
          if glabel list ${DEV} 1> /dev/null 2> /dev/null
          then
            if [ "${SIZE}" = "-" ]
            then
              SIZE=$( glabel list ${DEV} | grep -v -E '(gptid|ufsid)/' | grep -A 256 "Name: ${DEV}" | grep -m 1 "Mediasize:" | awk 'END{print $3}' | tr -d '()' )
            fi
            # LABEL=$( glabel list ${DEV} | grep Name | head -1 | awk '{print $3}' )
            # LABEL=$( glabel list ${DEV} | grep Name | awk 'NR>1{exit}{print $3}' )
            LABEL=$( glabel list ${DEV} | grep -v -E '(gptid|ufsid)/' | grep -m 1 'Name:' | awk 'END{print $3}' )
            if echo "${LABEL}" | grep -q "label/" 1> /dev/null 2> /dev/null
            then
              LABEL=$( echo "${LABEL}" | sed 's|label/||g' | sed 's|gpt/||g' )
            fi
            if [ "${LABEL}" != "" ]
            then
              MOUNT=$( mount | grep /dev/label/${LABEL} | awk 'END{print $3}' )
              if [ "${MOUNT}" = "" ]
              then
                MOUNT=$( mount | grep /dev/${DEV} | awk 'END{print $3}' )
                if [ "${MOUNT}" = "" ]
                then
                  MOUNT=$( mount | grep /dev/gpt/${LABEL} | awk 'END{print $3}' )
                  if [ "${MOUNT}" = "" ]
                  then
                    MOUNT="<UNMOUNTED>"
                  fi
                fi
              fi
              if [ "${TYPE}" = "-" ]
              then
                TYPE=$( mount | grep /dev/label/${LABEL} | awk 'END{print $4}' | tr -d '(,)' )
                if [ "${TYPE}" = "" ]
                then
                  TYPE="-"
                fi
              fi
            fi
          fi
          # DEBUG
          # IF MOUNT STILL NOT DETECTED TRY LAST CHANCE
          # if [ "${MOUNT}" = "" ]
          # then
          #   MOUNT="<UNMOUNTED>"
          #   MOUNT=$( mount | grep /dev/${DEV} | awk '{print $3}' )
          #   if [ "${MOUNT}" = "" ]
          #   then
          #     MOUNT="<UNMOUNTED>"
          #   fi
          # fi
        fi
        # OUTPUT
        MAJ=$( echo ${MA_MI} | awk -F ':' '{print $1}' )
        MIN=$( echo ${MA_MI} | awk -F ':' '{print $2}' )
        printf "${FORMAT_L0}" ${DEV} ${MAJ} ${MIN} ${SIZE} ${TYPE} "-" ${MOUNT}
      fi
    done
