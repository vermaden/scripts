#! /bin/sh

# OPTIONS
  PORTS='           multimedia/ffmpeg'
# PORTS='audio/lame multimedia/ffmpeg sysutils/exfat-utils sysutils/fusefs-exfat'

# ONLY root CAN BUILD PACKAGES/PORTS
if [ "$( whoami )" != "root" ]
then
  echo "ER: only 'root' may use this script"
  exit 1
fi

case ${1} in
  # REBUILD PACKAGES
  (b|build)
    for PORT in ${PORTS}
    do
      pkg unlock -y ${PORT} 1> /dev/null 2> /dev/null
      idprio 10 env BATCH=yes DISABLE_VULNERABILITIES=yes make -C /usr/ports/${PORT} build deinstall install clean &
      MAKE=${!}
      rctl -a process:${MAKE}:pcpu:deny=40
      wait ${MAKE}
      # pkg lock -y ${PORT}
    done
    ;;

  # CLEAN
  (c|clean)
    for PORT in ${PORTS}
    do
      make -C /usr/ports/${PORT} clean
    done
    ;;

  # USAGE
  (*)
    echo "usage: ${0##*/} b|c|build|clean"
    exit 1
    ;;

esac
