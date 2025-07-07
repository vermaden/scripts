#! /bin/sh

__usage() {
  local NAME=${0##*/}
  echo "USAGE:"
  echo "  ${NAME} (without any arguments)"
  echo
  echo "OPTIONS(s):"
  echo "  -u | --unmount  unmount all 'optional' filesystems"
  echo
  exit 1
}

# SUPPORT OPTIONS
case ${1} in
  (-u|--unmount)
    ${0} \
      | sed 1d \
      | grep -v '^devfs' \
      | awk '{print $NF}' \
      | while read DIR
        do
          umount    "${DIR}" 2> /dev/null
          umount -f "${DIR}" 2> /dev/null
          echo "INFO: dir '${DIR}' unmounted"
        done
    exit 0
    ;;
  (-h|--help|help)
    __usage
    ;;
esac

# HEADER
HEAD='FSTYPE DEV MNT'

# MOUNTABLE ZFS MOUNTPOINTS
ZFS=$( zfs get canmount | grep 'canmount  on' )

# fstab(5) MOUNTPOINTS
FSTAB=$( grep '^[^#]' /etc/fstab )

# CURRENTLY MOUNTED FILESYSTEMS
MOUNT=$( mount )

# REMOVE JAILS MOUNTPOINTS
while read PLACE
do
  # MAKE SURE TO CHECK FROM BEFINING '^' OF THE MOUNTPOINT
  if [ "${PLACE}" != "" ]
  then
    if echo "${MOUNT}" | awk '{print $3}' | grep -q "^${PLACE}"
    then
      MOUNT=$( echo "${MOUNT}" | grep -v "${PLACE}" )
    fi
  fi
done << EOF
  $( jls                   \
       | sed 1d            \
       | awk '{print $NF}' \
   )
EOF

# REMOVE /etc/rc.d/linux MOUNTS
_emul_path=$( sysctl -n compat.linux.emul_path )
COMPAT_LINUX_LIST=$( awk '/linux_mount.*-o / {print $3}' /etc/rc.d/linux )
for I in ${COMPAT_LINUX_LIST}
do
  COMPAT_LINUX_MNT="${COMPAT_LINUX_MNT} $( eval echo "${I}" )"
done
unset _emul_path COMPAT_LINUX_LIST
COMPAT_LINUX_MNT=$( echo "${COMPAT_LINUX_MNT}" | tr ' ' '\n' )

# CREATE LIST OF MANUALLY FILESYSTEMS BY REMOVING CONFIGURED MOUNTPOINTS
LIST=$(
  echo "${MOUNT}" \
    | while read DEV on MNT OPTS
      do
        echo "${ZFS}"              | grep -q "${MNT}" && continue
        echo "${FSTAB}"            | grep -q "${MNT}" && continue
        echo "${COMPAT_LINUX_MNT}" | grep -q "${MNT}" && continue
        OPTS=$( echo ${OPTS} | awk -F',' '{print $1}' | tr -d '()' )
        echo ${OPTS} ${DEV} ${MNT}
      done )

# IF LIST IS NOT EMPTY THEN PRINT IT FORMATTED BY column(1) COMMAND
if [ "${LIST}" != "" ]
then
  (
    echo "${HEAD}"
    echo "${LIST}"
  ) | column -t
fi

