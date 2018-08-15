#! /bin/sh

SUDO_WHICH=0
SUDO=0
DOAS_WHICH=0
DOAS=1
ROOT=0

# CHECK doas(8) WITH which(1)
if which doas 1> /dev/null 2> /dev/null
then
  DOAS_WHICH=1
else
  DOAS_WHICH=0
fi

# CHECK sudo(8) WITH which(1)
if which sudo 1> /dev/null 2> /dev/null
then
  SUDO_WHICH=1
else
  SUDO_WHICH=0
fi

# CHECK USER WITH whoami(1)
if [ "$( whoami )" = "root" ]
then
  ROOT=1
fi

# CHOOSE ONE FROM doas(8) AND sudo(8)
if [ ${DOAS_WHICH} -eq 1 -o ${SUDO_WHICH} -eq 1 ]
then
  if [   ${DOAS} -eq 0 -a ${SUDO} -eq 1 -a ${SUDO_WHICH} -eq 1 ]
  then
    CMD=sudo
  elif [ ${DOAS} -eq 1 -a ${SUDO} -eq 0 -a ${DOAS_WHICH} -eq 1 ]
  then
    CMD=doas
  elif [ ${DOAS} -eq 1 -a ${SUDO} -eq 1 -a ${DOAS_WHICH} -eq 1 ]
  then
    CMD=doas
  fi
elif [ ${ROOT} -eq 1 ]
then
  CMD=''
else
  echo "NOPE: This script needs 'doas' or 'sudo' to work properly."
  exit 1
fi

unset SUDO_WHICH
unset DOAS_WHICH
unset ROOT

MNT=/media/blackbox
DIR=/data

mount -t nfs | grep -q ${MNT} || {
  # FSTAB
  # 10.0.0.2:/data /media/blackbox nfs rw,noauto,noatime,intr
  # ${CMD} mount /media/blackbox

  ${CMD} mkdir -p ${MNT}
  ${CMD} chown 1000:1000 ${MNT}
  ${CMD} mount -t nfs \
    -o rw,rsize=1048576,wsize=1048576,readahead=4,retrycnt=1,retrans=1,tcp,noauto,noatime,soft,intr,proto=tcp \
    10.0.0.2:/data ${MNT}
}

caja --browser --no-desktop ${MNT} &

echo '1' >> ~/scripts/stats/${0##*/}
