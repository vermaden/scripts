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

# DISPLAY HELP/USAGE/EXAMPLES
__usage() {
  local NAME="${0##*/}"
  echo "usage:"
  echo
  echo "  BASIC USAGE INFORMATION"
  echo "  ======================="
  echo "  # ${NAME} [DISK]"
  echo
  echo "example(s):"
  echo
  echo "  LIST ALL BLOCK DEVICES IN SYSTEM"
  echo "  --------------------------------"
  echo "  # ${NAME}"
  echo "  DEVICE         MAJ:MIN SIZE TYPE                      LABEL MOUNT"
  echo "  ada0             0:5b  932G GPT                           - -"
  echo "    ada0p1         0:64  200M efi                    efiboot0 <UNMOUNTED>"
  echo "    ada0p2         0:65  512K freebsd-boot           gptboot0 -"
  echo "    <FREE>         -:-   492K -                             - -"
  echo "    ada0p3         0:66  931G freebsd-zfs                zfs0 <ZFS>"
  echo
  echo "  LIST ONLY da1 BLOCK DEVICE"
  echo "  --------------------------"
  echo "  # ${NAME} da1"
  echo "  DEVICE         MAJ:MIN SIZE TYPE                      LABEL MOUNT"
  echo "  da1              0:80  2.0G MBR                           - -"
  echo "    da1s1          0:80  2.0G freebsd                       - -"
  echo "      da1s1a       0:81  1.0G freebsd-ufs                root /"
  echo "      da1s1b       0:82  1.0G freebsd-swap               swap SWAP"
  echo
  echo "hint(s):"
  echo
  echo "  DISPLAY ALL DISKS IN SYSTEM"
  echo "  ---------------------------"
  echo "  # sysctl kern.disks"
  echo "  kern.disks: ada0 da0 da1"
  echo
  exit 1
}
# __usage() ENDED

# GET MAJOR/MINOR NUMBERS
__major_minor() { # 1=DEV
  local DEV=${1}
  MA_MI=$( ls -l /dev/${DEV} | awk 'END{print $5}' | tr 'x' ':' )
  if [ "${MA_MI}" = "0," ]
  then
    MA_MI=$( ls -l /dev/${DEV} | awk 'END{print $5"x"$6 }' | tr -d ',' | tr 'x' ':' )
  fi
  MAJ=$( echo ${MA_MI} | awk -F ':' '{print $1}' )
  MIN=$( echo ${MA_MI} | awk -F ':' '{print $2}' )
}
# __major_minor() ENDED

# GET SIZE FOR PROVIDER
__get_size() { # 1=LINE
  local LINE="${1}"
  SIZE=$( echo "${LINE}" | awk '{print $NF}' | tr -d '()' )
  if [ "${SIZE}" = "" ]
  then
    SIZE="-"
  fi
}
# __get_size() ENDED

# DETECT IF SWAP IS BEING USED
__swap_detect() { # 1=TYPE
  TYPE="${1}"
  if [ "${TYPE}" = "freebsd-swap" ]
  then
    if [ "${LABEL}" != "-" ]
    then
      if swapinfo | grep -q -- ${LABEL}
      then
        MOUNT="SWAP"
        return
      fi
    fi
    if [ "${PART}" != "" ]
    then
      if swapinfo | grep -q -- ${PART}
      then
        MOUNT="SWAP"
        return
      fi
    fi
    if [ "${NAME}" != "" ]
    then
      if swapinfo | grep -q -- ${NAME}
      then
        MOUNT="SWAP"
        return
      fi
    fi
    MOUNT="<UNMOUNTED>"
  fi
}
# __swap_detect() ENDED

__mount_label() { # 1=TARGET
  local TARGET="${1}"
  local MOUNT_FOUND=0
  LABEL="-"
  MOUNT="-"

  # TRY CLASSIC MOUNT POINT WITH DEVICE NAME
  MOUNT=$( mount | grep "/dev/${TARGET} " | awk 'END{print $3}' )
  if [ "${MOUNT}" = "" ]
  then
    MOUNT="-"
  else
    local MOUNT_FOUND=1
  fi

  # GET LABEL FOR UFS OR ZFS FILESYSTEM
  case ${TYPE} in
    (freebsd-ufs)
      LABEL=$( tunefs -p /dev/${TARGET} 2>&1 | awk '/volume label/ {print $NF}' )
      if [ "${LABEL}" = "(-L)" ]
      then
        LABEL="-"
      fi
      ;;
    (freebsd-zfs)
      MOUNT="<ZFS>"
      local MOUNT_FOUND=1
      ;;
  esac

  # TRY LABEL MOUNTPOINT
  if [ "${MOUNT_FOUND}" != "1" ]
  then
    # TRY GLABEL MOUNTPOINT AS MSDOSFS MOUNT IS NOT POSSIBLE WITHOUT GPT/MBR
    local GLABEL=$( glabel status | grep -v ufsid | grep ${TARGET}\$ )
    if [ "${GLABEL}" = "" ]
    then
      LABEL="-"
    else
      while read PROVIDER STATUS DEVICE
      do
        MOUNT=$( mount | grep "${PROVIDER}" | awk 'END{print $3}' )
        if [ "${MOUNT}" = "" ]
        then
          MOUNT="-"
        fi
        LABEL=$( echo "${GLABEL}" | grep -m 1 "${TARGET}" | awk '{print $1}' )
      done << EOF
        $( echo "${GLABEL}" | sed '/^s*$/d' )
EOF
    fi
  fi
}
# __mount_label() ENDED

# WHEN GPART OUTPUT EXISTS (partition table / not entire device)
__gpart_present() {
  # ------------------------------------------------------------------------- #
  # GPART PRESENT                                                             #
  # ------------------------------------------------------------------------- #
  echo "${GPART}" \
    | tr -d '=>' \
    | while read LINE
      do
        # SKIP EMPTY LINES
        if [ "${LINE}" = "" ]
        then
          continue
        fi
        # ------------------------------------------------------------------- #
        # GPART ENTIRE DEVICE                                                 #
        # VISITED ONLY ONCE WHEN ${PREFIX} IS NOT SET                         #
        # ------------------------------------------------------------------- #
        if [ "${PREFIX}" = "" ]
        then
          # GET MAJOR/MINOR DATA
          __major_minor ${DEV}

          # GET PROVIDER SIZE
          __get_size "${LINE}"

          # GET PROVIDER TYPE
          TYPE=$( echo "${LINE}" | awk 'END{print $4}' )

          # GET LABEL AND MOUNT
          __mount_label ${DEV}

          # OUTPUT
          printf "${FORMAT_L0}" ${DEV} ${MAJ} ${MIN} ${SIZE} ${TYPE} ${LABEL} ${MOUNT}
          if [ -e /dev/${DEV}.eli ]
          then
            # GET GELI MOUNT/LABEL/MAJOR/MINOR
            __major_minor ${DEV}.eli
            __mount_label ${DEV}.eli
            printf "${FORMAT_L0}" ${DEV}.eli ${MAJ} ${MIN} ${SIZE} ${TYPE} ${LABEL} ${MOUNT}
          fi

          # DETECT PARTITION SCHEMA (GPT/MBR)
          case "${LINE}" in
            (*GPT*) PREFIX=p; continue ;;
            (*MBR*) PREFIX=s; continue ;;
            (*)     PREFIX=x; continue ;;
          esac
        fi

        # ------------------------------------------------------------------- #
        # GPART PARTITIONS                                                    #
        # VISITED MANY TIMES EACH TIME FOR EACH PARTITION/SLICE               #
        # ------------------------------------------------------------------- #
        # GET PROVIDER SIZE
        __get_size "${LINE}"

        # PRINT FREE SPACE
        if echo "${LINE}" | grep -q -- "- free -" 1> /dev/null 2> /dev/null
        then
          printf "${FORMAT_L1}" "<FREE>" - - ${SIZE} - - -
          continue
        fi

        # USED / PART
        NAME=$( echo "${LINE}" | awk 'END{print $3}' )
        TYPE=$( echo "${LINE}" | awk 'END{print $4}' )

        # DEVICE NAME WITH PARTITION
        if [ "${DEV}" != "${NAME}" ]
        then
          NAME="${DEV}${PREFIX}${NAME}"
        fi

        # GET LABEL AND MOUNT
        __mount_label ${NAME}

        # SWAP ON/OFF DETECTION
        __swap_detect "${TYPE}"

        # ZFS TYPE SETUP
        if [ "${TYPE}" = "freebsd-zfs" ]
        then
          MOUNT="<ZFS>"
        fi

        # GET MAJOR/MINOR DATA
        __major_minor ${NAME}

        # OUTPUT
        printf "${FORMAT_L1}" ${NAME} ${MAJ} ${MIN} ${SIZE} ${TYPE} ${LABEL} ${MOUNT}
        if [ -e /dev/${NAME}.eli ]
        then
          # GET GELI MOUNT/LABEL/MAJOR/MINOR
          __major_minor ${NAME}.eli
          __mount_label ${NAME}.eli
          printf "${FORMAT_L1}" ${NAME}.eli ${MAJ} ${MIN} ${SIZE} ${TYPE} ${LABEL} ${MOUNT}
        fi

        # ----------------------------------------------------------------------- #
        # USED / bsdlabel(8)                                                      #
        # ----------------------------------------------------------------------- #
        if [ "${TYPE}" = "freebsd" -a "${PREFIX}" != "p" ]
        then
          BSDGPART=$( gpart show ${NAME} 2> /dev/null )
          if [ "${BSDGPART}" != "" ]
          then
            echo "${BSDGPART}" \
              | grep -v '=>' \
              | while read BSDLINE
                do
                  # SKIP EMPTY LINES
                  if [ "${BSDLINE}" = "" ]
                  then
                    continue
                  fi
                  # ------------------------------------------------------------- #
                  # bsdlabel(8) PARTITIONS                                        #
                  # VISITED MANY TIMES EACH TIME FOR EACH PARTITION               #
                  # ------------------------------------------------------------- #
                  # PRINT FREE SPACE
                  if echo "${BSDLINE}" | grep -q -- "- free -" 1> /dev/null 2> /dev/null
                  then
                    # DO NOT DISPLAY 16 SECTORS LONG <FREE> IN EACH bsdlabel(8) SCHEMA
                    BEG=$( echo "${BSDLINE}" | awk 'END{print $1}' )
                    END=$( echo "${BSDLINE}" | awk 'END{print $2}' )
                    if [ "$(( ${END} - ${BEG} ))" = "16" ]
                    then
                      continue
                    fi

                    # GET PROVIDER SIZE
                    __get_size "${BSDLINE}"

                    # OUTPUT
                    printf "${FORMAT_L2}" "<FREE>" - - ${SIZE} - - -
                    continue
                  else
                    # USED SPACE
                    __get_size "${BSDLINE}"
                    PART=$( echo "${BSDLINE}" | awk 'END{print $3}' )
                    TYPE=$( echo "${BSDLINE}" | awk 'END{print $4}' )

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

                  # GET LABEL AND MOUNT
                  __mount_label ${PART}

                  # WORKAROUND FOR (null) LABEL
                  if [ "${LABEL}" = "" -o "${LABEL}" = "(null)" ]
                  then
                    LABEL="-"
                  fi

                  # GET MAJOR/MINOR DATA
                  __major_minor ${PART}

                  # SET PROPER MOUNT FOR bsdlabel(8) PARTITION
                  if [ "${TYPE}" = "freebsd-boot" -o "${TYPE}" = "freebsd" ]
                  then
                    MOUNT="-"
                  fi

                  # SWAP ON/OFF DETECTION
                  __swap_detect "${TYPE}"

                  # OUTPUT
                  printf "${FORMAT_L2}" ${PART} ${MAJ} ${MIN} ${SIZE} ${TYPE} ${LABEL} ${MOUNT}
                  if [ -e /dev/${PART}.eli ]
                  then
                    # GET GELI MOUNT/LABEL/MAJOR/MINOR
                    __major_minor ${PART}.eli
                    __mount_label ${PART}.eli
                    printf "${FORMAT_L2}" ${PART}.eli ${MAJ} ${MIN} ${SIZE} ${TYPE} ${LABEL} ${MOUNT}
                  fi

                done
          fi
        fi
      done
}
# __gpart_present() ENDED

# WHEN GPART OUTPUT DO NOT EXISTS (no partition table / entire device)
__gpart_absent() {
  # ------------------------------------------------------------------------- #
  # GPART ABSENT                                                              #
  # ------------------------------------------------------------------------- #
  # GET SIZE INFORMATION FROM diskinfo(8) OUTPUT
  SIZE=$( diskinfo -v ${DEV} | awk '/mediasize in bytes/ {print $NF}' | tr -d '()' )

  # GET MAJOR/MINOR DATA
  __major_minor ${DEV}

  # TRY TO DETECT FS TYPE
  TYPE=$( fstyp /dev/${DEV} 2> /dev/null )
  if [ "${TYPE}" = "" ]
  then
    # ZFS DETECTION
    if head -c 32000 /dev/${DEV} | strings | grep -q pool_guid 1> /dev/null 2> /dev/null
    then
      # THIS IS ZFS
      TYPE=freebsd-zfs

      # ZFS USUALLY HAVE LOTS OF MOUNT POINTS SO USE '<ZFS>' HERE
      MOUNT="<ZFS>"
    else
      # IF ITS NOT ZFS THEN FIND PROPER MOUNT POINT
      TYPE="-"

      # GET LABEL AND MOUNT
      __mount_label ${DEV}

    fi
  fi

  # GET msdosfs LABEL BY HAND
  LABEL="-"
  case ${TYPE} in
    (msdosfs)
      LABEL=$( file -s /dev/${DEV} | tr ',' '\n' | awk -F '"' '/label:/ {print $2}' )
      if [ "${LABEL}" = "" ]
      then
        LABEL="-"
      fi
      ;;
  esac

  # OUTPUT
  printf "${FORMAT_L0}" ${DEV} ${MAJ} ${MIN} ${SIZE} ${TYPE} ${LABEL} ${MOUNT}
  if [ -e /dev/${DEV}.eli ]
  then
    # GET GELI MOUNT/LABEL/MAJOR/MINOR
    __major_minor ${DEV}.eli
    __mount_label ${DEV}.eli
    printf "${FORMAT_L0}" ${DEV}.eli ${MAJ} ${MIN} ${SIZE} ${TYPE} ${LABEL} ${MOUNT}
  fi
}
# __gpart_absent() ENDED

# PARSE ARGUMENTS IF THERE ARE ANY
if [ ${#} -eq 0 ]
then
  # NO ARGUMENTS MEANS ALL DEVICES
  DISKS=$( ( sysctl -n kern.disks; mdconfig -l ) | tr ' ' '\n' )
elif [ ${#} -eq 1 ]
then
  # SINGLE ARGUMENT MEANS SINGLE DISK OR HELP
  case ${1} in
    (h|-h|--h|help|-help|--help)
      __usage
      ;;
  esac
  # SINGLE DISK CHECK
  if sysctl -n kern.disks | grep -q -- "${1}"
  then
    DISKS="${1}"
  elif mdconfig -l | grep -q -- "${1}"
  then
    DISKS="${1}"
  else
    echo "NOPE: disk '${1}' does not exist in the system"
    echo
    __usage
  fi
else
  # ONLY '0' and '1' ARGUMENTS ARE COVERED
  __usage
fi

# SET OUTPUT FORMAT AND PRINT HEADER
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
      GPART=$( gpart show ${DEV} 2> /dev/null )
      if [ "${GPART}" != "" ]
      then
        __gpart_present
      else
        __gpart_absent
      fi
    done
