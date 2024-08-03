#! /bin/sh

if [ ${#} -eq 0 -o ${#} -ne 3 ]
then
  echo "usage: ${0##*/} ARATE VRATE FILE"
  echo
  exit 1
fi

ARATE=${1}
VRATE=${2}

nice -n 20 \
  ffmpeg -y -i "${3}" -acodec ac3 -ab ${1}k -aq 50 -vcodec libx264 -threads 1 \
         -minrate 0k -bufsize ${2}k -maxrate ${2}k -s 1280x720 "${3}".x264.mkv
