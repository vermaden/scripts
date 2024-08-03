#! /bin/sh

# 1=mmcsd0s1
# 2=photo.NEW

# HELP
if [ ${#} -ne 2 ]
then
  echo "usage: $( basename ${0} ) SOURCE-DIR TARGET-DIR"
  echo
  echo "example:"
  echo "          photo-flow.sh /media/mmcsd0s1 ~/photo.NEW"
  echo
  exit 1
fi

# CHECK SOURCE DIR
if [ -d "${1}" ]
then
  SOURCE="${1}"
else
  echo "ER: source dir '${1}' does not exists"
  exit 1
fi

# CHECK TARGET DIR
if [ -d "${2}" ]
then
  TARGET="${2}"
else
  echo "ER: target dir '${2}' does not exists"
  exit 1
fi

# CREATE DUMP DIR
DUMP_DIR=$( date +%Y.%m.%d.DUMP )
mkdir -p "${TARGET}/${DUMP_DIR}"

# COPY FILES
cp -av ${SOURCE}/DCIM/*/*              "${TARGET}/${DUMP_DIR}"
cp -av ${SOURCE}/PRIVATE/M4ROOT/CLIP/* "${TARGET}/${DUMP_DIR}"

# RENAME AND CONVERT
cd "${TARGET}/${DUMP_DIR}"
photo-rename-images.sh
photo-rename-movies.sh
photo-requality.sh 92
for I in *.MP4
do
  photo-movie-audio-ac3.sh 160 25000 ${I}
done
