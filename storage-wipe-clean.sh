#! /bin/sh

# CHECK USER WITH whoami(1)
[ "$( whoami )" = "root" ] || echo "NOPE: run '$( basename ${0} )' as root user" || exit 1

# CHECK ARGUMENTS
if [ ${#} -eq 0 ]
then
  echo "usage: $( basename ${0} ) DEVICE"
  echo
  exit 1
fi

# CHECK DEVICE EXISTS
DEVSET='0'
[ "${DEVSET}" = "0" -a -e /dev/${1} ] && DEV=/dev/${1} && DEVSET=1
[ "${DEVSET}" = "0" -a -e ${1}      ] && DEV=${1}      && DEVSET=1
if [ -z ${DEV} ]
then
  echo "NOPE: disk '${1}' does not exists"
  echo
  exit 1
fi

# ASK USER FOR DESRUPTIVE ACTIONS
echo    "INFO: wipe clean disk '${DEV}' along with all data on it?"
echo -n "READ: are you OK with that? (y/n): "
read YESNO

# CHECK YES/NO ANSWER AND ACT ACCORDINGLY
case ${YESNO} in
  (y|yes|ok) ;;
  (*)
    echo "NOPE: user did not wanted to continue"
    echo
    exit 1
    ;;
esac

# WIPE CLEAN MBR/GPT HEADER
echo
echo "# gpart destroy -F ${DEV}"
        gpart destroy -F ${DEV}

# WIPE CLEAN ZFS LABEL
echo
echo "# zpool labelclear -f ${DEV}"
        zpool labelclear -f ${DEV}

# WIPE CLEAN DISK AT BEGIN
echo
echo "# dd bs=1m count=20 if=/dev/zero of=${DEV} status=progress"
        dd bs=1m count=20 if=/dev/zero of=${DEV} status=progress

# WIPE CLEAN DISK AT END
# DISKINFO=$( diskinfo -v ${DEV} )
# MED_SIZE=$( echo "${DISKINFO}" | awk '/# mediasize in sectors/ {print $1}' )
# SEC_SIZE=$( echo "${DISKINFO}" | awk '/# sectorsize/           {print $1}' )
# DD_OSEEK=$(( ${MED_SIZE} - ( ${SEC_SIZE} * 40 ) ))
# echo
# echo "# dd bs=${SEC_SIZE} if=/dev/zero of=${DEV} oseek=${DD_OSEEK} status=progress"
#         dd bs=${SEC_SIZE} if=/dev/zero of=${DEV} oseek=${DD_OSEEK} status=progress

echo

