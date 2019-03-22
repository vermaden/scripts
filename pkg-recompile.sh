#! /bin/sh

# OPTIONS
  PORTS='audio/lame multimedia/ffmpeg'
# PORTS='audio/lame multimedia/ffmpeg sysutils/exfat-utils sysutils/fusefs-exfat'

# ONLY root CAN BUILD PACKAGES/PORTS
if [ "$( whoami )" != "root" ]
then
  echo "ER: only 'root' may use this script"
  exit 1
fi

case ${1} in
  # REBUILD PACKAGES
  (build)
    # DISMISS ALL PROMPTS
    # for PORT in ${PORTS}
    # do
    #   make -C /usr/ports/${PORT} config-recursive
    # done

    # UNLOCK BUILD LOCK
    for PORT in ${PORTS}
    do
      pkg unlock -y ${PORT}
      idprio 10 env BATCH=yes make -C /usr/ports/${PORT} build deinstall install clean &
      MAKE=${!}
      rctl -a process:${MAKE}:pcpu:deny=40
      wait ${MAKE}
      pkg lock -y ${PORT}
    done
    ;;

  # CLEAN
  (clean)
    for PORT in ${PORTS}
    do
      make -C /usr/ports/${PORT} clean
    done
    ;;

  # USAGE
  (*)
    echo "usage: ${0##*/} build|clean"
    exit 1
    ;;

esac

echo '1' >> ~/scripts/stats/${0##*/}
