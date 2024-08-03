#! /bin/sh

if [ ${#} -eq 0 -o ${#} -ne 2 ]
then
  echo "usage: ${0##*/} VRATE FILE"
  echo
  exit 1
fi

VRATE=${1}

nice -n 20 \
  ffmpeg -y -i "${2}" -acodec copy -vcodec libx264 -threads 1 \
         -minrate 0k -bufsize ${1}k -maxrate ${1}k -s 1280x720 "${2}".x264.mkv
