#! /bin/sh

CMD=doas
MNT=/media/nfs
DIR=/export/nfs

mount -t nfs \
  | grep -q ${MNT} || {
    ${CMD} mkdir -p ${MNT}
    ${CMD} chown 1000:1000 ${MNT}
    ${CMD} mount -t nfs \
      -o rw,rsize=1048576,wsize=1048576,readahead=4,retrycnt=1 \
      -o retrans=1,tcp,noauto,noatime,soft,intr,proto=tcp \
      nas:${DIR} ${MNT}
}

caja --browser --no-desktop ${MNT} &

echo '1' >> ~/scripts/stats/$( basename ${0} )
