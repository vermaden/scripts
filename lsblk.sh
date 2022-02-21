#! /bin/sh

# Copyright (c) 2016-2021 Slawomir Wojciech Wojtczak (vermaden)
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

# DISPLAY VERSION
if [ "${1}" = "--version" -o \
     "${1}" =  "-version" -o \
     "${1}" =   "version" ]
then
  echo
  echo "  ___     ___   ___ __       _ _ _____    "
  echo "  \  \  __\__\__\  \  \  __ / / /     \   "
  echo "   \  \/  __/    \  \  \/ // / /   .   \  "
  echo "    \  \___ \  \  \  \_   \\\ \ \    \  / "
  echo "     \___\__/\____/\___\/\_\\\_\_\____\/  "
  echo
  echo "lsblk 3.7 2021/08/28"
  echo
  exit 0
fi

# DISPLAY HELP/USAGE/EXAMPLES
__usage() {
  local NAME="${0##*/}"
  cat << __EOF
usage:

  BASIC USAGE INFORMATION
  =======================
  # ${NAME} [DISK]
  # ${NAME} -d | --disks

example(s):

  LIST ALL BLOCK DEVICES IN SYSTEM
  --------------------------------
  # ${NAME}
  DEVICE         MAJ:MIN SIZE TYPE                      LABEL MOUNT
  ada0             0:92  932G GPT                           - -
    ada0p1         0:100 200M efi                    efiboot0 -
    ada0p2         0:101 512K freebsd-boot           gptboot0 -
    <FREE>         -:-   492K -                             - -
    ada0p3         0:102 931G freebsd-zfs                zfs0 <ZFS>
    ada0p3.eli     0:106 931G freebsd-zfs                   - <ZFS>

  LIST ONLY da1 BLOCK DEVICE
  --------------------------
  # ${NAME} da1
  DEVICE         MAJ:MIN SIZE TYPE                      LABEL MOUNT
  da1              0:80  2.0G MBR                           - -
    da1s1          0:80  2.0G freebsd                       - -
      da1s1a       0:81  1.0G freebsd-ufs                root /
      da1s1b       0:82  1.0G freebsd-swap               swap SWAP

  LIST ENTIRE DISKS
  -----------------
  # ${NAME} -d
  DEVICE SIZE MODEL
  ada0   1.8T Samsung SSD 860 QVO 2TB
  ada1   119G SAMSUNG SSD PM830 mSATA 128GB

hint(s):

  DISPLAY PHYSICAL DISKS
  ----------------------
  # sysctl kern.disks
  kern.disks: ada0 da0 da1

  DISPLAY MEMORY BACKED DISKS
  ---------------------------
  # mdconfig -l
  md0

__EOF
  exit 1
}
# __usage() ENDED

# GET MAJOR/MINOR NUMBERS
__major_minor() { # 1=DEV
  local DEV=${1}
  MAJ=$( stat -f "%Hr" /dev/${DEV} )
  MIN=$( stat -f "%Lr" /dev/${DEV} )
}
# __major_minor() ENDED

# DETECT IF SWAP IS BEING USED
__swap_mount() { # 1=DEV
  local DEV="${1}"
  SWAP_FOUND=0

  # DETECT SWAP BY RAW DEVICE
  if swapctl -l | grep -q -- ${DEV} 2> /dev/null
  then
    TYPE=freebsd-swap
    MOUNT=SWAP
    LABEL="-"
    SWAP_FOUND=1
    return
  fi

  # DETECT SWAP BY LABEL
  while read LABELER GARBAGE PROVIDER
  do
    if [ "${DEV}" = "${PROVIDER}" ]
    then
      if swapctl -l | grep -q -- ${LABELER} 2> /dev/null
      then
        TYPE=freebsd-swap
        LABEL=${LABELER}
        MOUNT=SWAP
        SWAP_FOUND=1
        break
      fi
    fi
  done << __EOF
    $( echo "${GLABEL}" )
__EOF
}
# __swap_mount() ENDED

# DETECT TYPE WITH fstyp(8) TOOL
__type() { # 1=DEV
  local DEV=${1}
  TYPE=$( fstyp -u /dev/${DEV} 2> /dev/null )
  [ "${TYPE}" = "" ] && __swap_mount ${DEV}
  [ "${TYPE}" = "" ] && TYPE="-"
}
# __type() ENDED

# DETECT MOUNT/LABEL IF POSSIBLE
__mount_label() { # 1=TARGET
  local TARGET="${1}"
  local MOUNT_FOUND=0
  local LABEL_FOUND=0
  LABEL="-"
  if [ "${SWAP_FOUND}" = "1" ]
  then
    local MOUNT_FOUND=1
  else
    MOUNT="-"
  fi

  # CHECK IF DEVICE EXISTS - IT NOT THEN EXIT FUNCTION
  [ ! -e /dev/${TARGET} ] && return

  # TRY CLASSIC MOUNT POINT WITH DEVICE NAME
  if [ "${MOUNT_FOUND}" != "1" ]
  then
    MOUNT=$( mount | grep "/dev/${TARGET} " | awk 'END{print $3}' )
    if [ "${MOUNT}" = "" ]
    then
      MOUNT="-"
    else
      local MOUNT_FOUND=1
    fi
  fi

  # GET LABEL/MOUNT FOR UFS/zfs(8)/msdosfs(8) FILESYSTEM
  case ${TYPE} in
    (freebsd-ufs)
      LABEL=$( tunefs -p /dev/${TARGET} 2>&1 | awk '/volume label/ {print $5}' )
      if [ "${LABEL}" = "" ]
      then
        LABEL="-"
      else
        LABEL="ufs/${LABEL}"
        local LABEL_FOUND=1
      fi
      ;;
    (freebsd-zfs)
      # zfs(8) IS NEVER MOUNTED BY RAW DEVICE NAME
      # SO NO NEED TO CHECK IF MOUNT_FOUND = 1 HERE
      MOUNT="<ZFS>"
      local MOUNT_FOUND=1
      ;;
    (msdosfs)
      LABEL=$( file -s /dev/${DEV} | tr ',' '\n' | awk -F '"' '/label:/ {print $2}' )
      if [ "${LABEL}" = "" ]
      then
        LABEL="-"
      else
        LABEL="msdosfs/${LABEL}"
        local LABEL_FOUND=1
      fi
      ;;
    (exfat)
      # IF exfatlabel(8) IS AVAIALBLE THEN READ exFAT LABEL
      if which exfatlabel 1> /dev/null 2> /dev/null
      then
        LABEL=$( exfatlabel /dev/${DEV} 2> /dev/null )
        if [ "${LABEL}" = "" ]
        then
          LABEL="-"
        else
          LABEL="exfat/${LABEL}"
          local LABEL_FOUND=1
        fi
      fi
      ;;
  esac

  # GET LABEL USING glabel(8)
  if [ "${LABEL_FOUND}" != "1" ]
  then
    # TRY GLABEL MOUNTPOINT AS msdosfs MOUNT IS NOT POSSIBLE WITHOUT GPT/MBR
    local GLABEL_GREP=$( echo "${GLABEL}" | grep -v ufsid | grep "${TARGET}\$" )
    if [ "${GLABEL_GREP}" = "" ]
    then
      LABEL="-"
    else
      while read PROVIDER STATUS DEVICE
      do
        LABEL=$( echo "${GLABEL_GREP}" | grep -m 1 " ${TARGET}"  | awk '{print $1}' )
        local LABEL_FOUND=1
        break
      done << ______EOF
        $( echo "${GLABEL_GREP}" )
______EOF
    fi
  fi

  # GET MOUNT USING glabel(8)
  if [ "${MOUNT_FOUND}" != "1" ]
  then
    # TRY GLABEL MOUNTPOINT AS msdosfs MOUNT IS NOT POSSIBLE WITHOUT GPT/MBR
    local GLABEL_GREP=$( echo "${GLABEL}" | grep -v ufsid | grep "${TARGET}\$" )
    if [ "${GLABEL_GREP}" != "" ]
    then
      while read PROVIDER STATUS DEVICE
      do
        MOUNT=$( mount | grep "${PROVIDER}" | awk 'END{print $3}' )
        if [ "${MOUNT}" = "" ]
        then
          MOUNT="-"
        else
          local MOUNT_FOUND=1
        fi
        break
      done << ______EOF
        $( echo "${GLABEL_GREP}" )
______EOF
    fi
  fi

  # GET MOUNT FROM fuse(8)
  if [ "${MOUNT_FOUND}" != "1" ]
  then
    if [ -e /dev/fuse ]
    then
      local FUSE_PIDS=$( fstat /dev/fuse 2> /dev/null | awk 'NR > 1 {print $3}' | tr '\n' ',' | sed '$s/.$//' )
    else
      local FUSE_PIDS=$( pgrep mount.exfat ntfs-3g 2> /dev/null | tr '\n' ',' | sed '$s/.$//' )
    fi
    if [ "${FUSE_PIDS}" != "" ]
    then
      local FUSE_MOUNTS=$( ps -p "${FUSE_PIDS}" -o command | sed 1d | sort -u )
      MOUNT=$( echo "${FUSE_MOUNTS}" | grep "/dev/${TARGET} " | sed 's|(mount.exfat-fuse)||g' | awk '{print $NF}' )
      # TRY automount(8) STATE FILE IF EXISTS
      if [ "${MOUNT}" = "" ]
      then
        if [ -f /var/run/automount.state ]
        then
          MOUNT=$( grep "^/dev/${TARGET} " /var/run/automount.state | awk '{print $NF}' )
          if ! mount -t fusefs | grep -q "${MOUNT}"
          then
            MOUNT="-"
          fi
        fi
      fi
      if [ "${MOUNT}" = "" ]
      then
        MOUNT="-"
      else
        local MOUNT_FOUND=1
      fi
    fi
  fi

  # GET LABEL FROM gpart(8)
  if [ "${LABEL_FOUND}" != "1" ]
  then
    LABEL=$( gpart show -p -l ${DEV} 2> /dev/null | sed 's|=>||g' | sed -E 's-\[.*\]--g' | grep "${TARGET} " | awk '{print $4}' )
    if [ "${LABEL}" = "" -o "${LABEL}" = "(null)" ]
    then
      LABEL="-"
    else
      LABEL="gpt/${LABEL}"
    fi
  fi
  SWAP_FOUND=0
}
# __mount_label() ENDED

# LIST BLOCK DEVICES
__list_block_devices() {
  # FIRST 1000 DEVICES OF EACH CLASS SHOULD DO
  (
    sysctl -n kern.disks | tr ' ' '\n'
    for I in ada da mmcsd md vtbd
    do
      ls -1 /dev/${I}[0-9]           2> /dev/null
      ls -1 /dev/${I}[0-9][0-9]      2> /dev/null
      ls -1 /dev/${I}[0-9][0-9][0-9] 2> /dev/null
    done
  ) \
      | sed 's|/dev/||g' \
      | sed -r "s/[[:cntrl:]]\[[0-9]{1,3}m//g" \
      | sort -u \
      | sed '/^s*$/d'
}
# __list_block_devices() ENDED

# PRINT DEVICES AND PARTITIONS
__print_parts() { # 1=NAME 2=TYPE 3=SIZE 4=SIZE_FREE
  local NAME=${1}
  local TYPE=${2}
  local SIZE=${3}
  local SIZE_FREE=${4}

  case ${TYPE} in
    (free)
      # REMOVE BRACKETS FROM SIZE
      local SIZE_FREE=$( echo ${SIZE_FREE} | tr -d '()' )
      # FIRST 16 SECTORS ARE ALWAYS EMPTY ON bsdlabel(8) PARTITION SCHEMA
      [ "${SIZE_FREE}" = "8.0K" ] && return
      # OUTPUT
      printf "${FORMAT}" "<FREE>" - - ${SIZE_FREE} "-" ${LABEL} ${MOUNT}
      ;;
    (*)
      # NEEDED FOR bsdlabel(8) ON WHOLE DISK WITHOUT PARTITION
      # WORKAROUND FOR gpart(8) BUG 241004
      # https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=241004
      if [ "${TYPE}" = "!0" ]
      then
        local TYPE=freebsd-ufs
      fi

      # REMOVE BRACKETS FROM SIZE
      local SIZE=$( echo ${SIZE} | tr -d '()' )
      [ "${LABEL}" = "" ] && local LABEL="-"
      [ "${MOUNT}" = "" ] && local MOUNT="-"
      __major_minor ${NAME}
      printf "${FORMAT}" ${NAME} ${MAJ} ${MIN} ${SIZE} ${TYPE} ${LABEL} ${MOUNT}
      if [ -e /dev/${NAME}.eli ]
      then
        # GET GELI MOUNT/LABEL/MAJOR/MINOR
        __major_minor ${NAME}.eli
        __type ${NAME}.eli
        __mount_label ${NAME}.eli
        printf "${FORMAT}" ${NAME}.eli ${MAJ} ${MIN} ${SIZE} ${TYPE} ${LABEL} ${MOUNT}
        MOUNT="-"
      fi
      ;;
  esac
}
# __print_parts() ENDED

# WHEN GPART OUTPUT EXISTS (partition table / not entire device)
__gpart_present() { # 1=DEV
  local DEV=${1}
  local TYPE="-"
  local LABEL="-"
  local MOUNT="-"
  local SIZE="-"
  local SIZE_FREE="-"
  # CHECK IF DEVICE EXISTS
  [ ! -e /dev/${DEV} ] && return

  # WORKAROUND FOR gpart(1) BUG 240998
  # https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=240998
  TYPE_EXFAT_HELPER_DEVICE=$( gpart show -p ${DEV} | head -1 | sed -E 's-\[.*\]--g' | awk '{print $5}' 2> /dev/null )
  if [ "${TYPE_EXFAT_HELPER_DEVICE}" = "MBR" ]
  then
    TYPE_EXFAT_HELPER=$( fstyp -u /dev/${DEV} 2> /dev/null )
    if [ "${TYPE_EXFAT_HELPER}" = "exfat" ]
    then
      TYPE=exfat
      case ${DEV} in
        (md*) SIZE=$( diskinfo -v ${DEV} 2> /dev/null| awk '/mediasize in bytes/ {print $NF}' | tr -d '()' ) ;;
        (*)   SIZE=$( geom disk list ${DEV} | awk '/Mediasize:/ {print $NF}' | tr -d '()' )                  ;;
      esac
      __mount_label ${DEV}
      # EXFAT FILESYSTEM ON WHOLE DEVICE IS INTERPETED AS MBR - FIX THAT
      if [ "${LABEL}" = "gpt/MBR" ]
      then

        # IF exfatlabel(8) IS AVAIALBLE THEN READ exFAT LABEL
        if which exfatlabel 1> /dev/null 2> /dev/null
        then
          LABEL=$( exfatlabel /dev/${DEV} 2> /dev/null )
          if [ "${LABEL}" = "" ]
          then
            local LABEL="-"
          else
            local LABEL="exfat/${LABEL}"
          fi
        fi

      fi
      __print_parts ${DEV} ${TYPE} ${SIZE} ${MOUNT}
      continue
    fi
  fi

  # READ PARTITIONS OF PROVIDER
  local GPART=$( gpart show -p ${DEV} 2> /dev/null | sed -E 's-\[.*\]--g' | sed 's|=>||g' )
  # PARSE gpart(8) OUTPUT
  echo "${GPART}" \
    | while read BEG END NAME TYPE SIZE SIZE_FREE
      do
        # VISITED ONLY ONCE FOR WHOLE DEVICE
        if [ ${LEVEL_DEV} = "0" ]
        then
          # WHOLE DEVICE
          LEVEL_DEV=1
          FORMAT="${FORMAT_L0}"
          __print_parts ${NAME} ${TYPE} ${SIZE} ${SIZE_FREE}
        else
          # PARTITION
          FORMAT="${FORMAT_L1}"
          # READ PARTITIONS OF PROVIDER
          local GPART_PARTS=$( gpart show -p ${NAME} 2> /dev/null | sed -E 's-\[.*\]--g' | sed 's|=>||g' )
          # PARSE gpart(8) OUTPUT
          if [ "${GPART_PARTS}" != "" ]
          then
            # PARTITION IN PARTITION
            [ ! -e /dev/${NAME} ] && return
            # PARSE DEVICE
            echo "${GPART_PARTS}" \
              | while read BEG END NAMEONE TYPE SIZE SIZE_FREE
                do
                  # VISITED ONLY ONCE FOR WHOLE DEVICE
                  if [ ${LEVEL_PAR} = "0" ]
                  then
                    # WHOLE DEVICE
                    LEVEL_PAR=1
                    FORMAT="${FORMAT_L1}"
                  else
                    # PARTITION
                    FORMAT="${FORMAT_L2}"
                  fi
                  # CHECK IF SWAP IS ENABLED FOR SWAP DEVICES
                  [ "${TYPE}" = "freebsd-swap" ] && __swap_mount ${NAMEONE}
                  __mount_label ${NAMEONE}
                  __print_parts ${NAMEONE} ${TYPE} ${SIZE} ${SIZE_FREE}
                done
          else
            # FILESYSTEM
            [ "${TYPE}" = "freebsd-swap" ] && __swap_mount ${DEV}
            __mount_label ${NAME}
            __print_parts ${NAME} ${TYPE} ${SIZE} ${SIZE_FREE}
          fi
        fi
      done
}
# __gpart_present() ENDED

# WHEN GPART OUTPUT DO NOT EXISTS (no partition table / entire device)
__gpart_absent() { # 1=DEV
  local DEV=${1}
  # EXIT IF DEVICE DOES NOT EXISTS
  [ ! -e /dev/${DEV} ] && return
  local MOUNT="-"
  case ${DEV} in
    (md*) local SIZE=$( diskinfo -v ${DEV} 2> /dev/null | awk '/mediasize in bytes/ {print $NF}' | tr -d '()' ) ;;
    (*)   local SIZE=$( geom disk list ${DEV} | awk '/Mediasize:/ {print $NF}' | tr -d '()' )                   ;;
  esac
  # WHEN SIZE IS NOT AVAILABLE ITS PROBABLY EMPTY CARD READER
  if [ "${SIZE}"  = "0B" ]
  then
    return
  fi
  local SIZE_FREE="-"
  __type ${DEV}
  __mount_label ${DEV}
  [ "${SIZE}"  = "" ] && local SIZE="-"
  [ "${TYPE}"  = "" ] && local TYPE="-"
  [ "${LABEL}" = "" ] && local LABEL="-"
  [ "${MOUNT}" = "" ] && local MOUNT="-"
  __print_parts ${DEV} ${TYPE} ${SIZE} ${SIZE_FREE}
}
# __gpart_absent() ENDED

# LIST ENTIRE DISKS ONLY
__list_disks() {
  local FORMAT="%-6s %4s %s\n"
  printf "${FORMAT}" DEVICE SIZE MODEL

  # DO THE JOB
  echo "${DISKS}" \
    | while read DEVICE
      do
        case ${DEVICE} in
          (md*)
            local SIZE=$( diskinfo -v ${DEVICE} 2> /dev/null| awk '/mediasize in bytes/ {print $NF}' | tr -d '()' )
            local MODEL="FreeBSD md(4) Memory Disk"
            ;;
          (*)
            local SIZE=$(  geom disk list ${DEVICE} | awk '/Mediasize:/ {print $NF}' | tr -d '()' )
            local MODEL=$( geom disk list ${DEVICE} | awk -F ':' '/descr:/ {print $2}' | sed '$s/^.//' )
            ;;
        esac
        [ "${SIZE}"  = "" ] && local SIZE="-"
        printf "${FORMAT}" ${DEVICE} ${SIZE} "${MODEL}"
      done
}
# __list_disks() ENDED

# PARSE ARGUMENTS IF THERE ARE ANY
LEVEL_DEV=0
LEVEL_PAR=0
GLABEL=$( glabel status | sed 1d | grep -v gptid )
DISKS=$( __list_block_devices )
case ${#} in
  (0)
    # LIST ALL DISKS
    :
    ;;
  (1)
    # SINGLE ARGUMENT MEANS 'SINGLE DISK' OR 'ENTIRE DISKS ONLY' OR 'HELP'
    case ${1} in
      (h|-h|--h|help|-help|--help)
        __usage
        ;;
      (-d|--disks)
        __list_disks
        exit 0
        ;;
    esac
    # SINGLE DISK CHECK
    if echo "${DISKS}" | grep -q -- "${1}"
    then
      DISKS="${1}"
    else
      echo "NOPE: disk '${1}' does not exist in the system"
      echo
      __usage
    fi
    ;;
  (*)
    # ONLY '0' and '1' ARGUMENTS ARE COVERED
    __usage
    ;;
esac

# SET OUTPUT FORMAT AND PRINT HEADER
    FORMAT_L0="%-14s %3s:%-3s %4s %-18s %32s %s\n"
  FORMAT_L1="  %-12s %3s:%-3s %4s %-18s %32s %s\n"
FORMAT_L2="    %-10s %3s:%-3s %4s %-18s %32s %s\n"
FORMAT="${FORMAT_L0}"
printf "${FORMAT}" DEVICE MAJ MIN SIZE TYPE LABEL MOUNT

# LIST ALL PARTITIONS OF ALL DISKS
echo "${DISKS}" \
  | while read DEVICE
    do
      if gpart show ${DEVICE} 1> /dev/null 2> /dev/null
      then
        __gpart_present ${DEVICE}
      else
        __gpart_absent ${DEVICE}
      fi
    done
