#! /bin/sh

__usage() {
  echo "usage: ${0##*/} QUALITY"
  exit 1
}

if [ ${#} -eq 0 -o ${#} -ne 1 ]
then
  __usage
fi

DESIRED=${1}

(
  find . -type f -iname \*\.jpg
  find . -type f -iname \*\.JPG
  find . -type f -iname \*\.jpe
  find . -type f -iname \*\.JPE
  find . -type f -iname \*\.jpeg
  find . -type f -iname \*\.JPEG
) | sort -u \
  | while read FILE
    do
      QUALITY=$( identify -format %Q "${FILE}" )

      if [ "${QUALITY}" = "" ]
      then
        echo "ERROR: count not get QUALITY value from the '${FILE}' file."
        continue
      fi

      if [ ${QUALITY} -lt ${DESIRED} ]
      then
        continue
      else
        convert -quality ${DESIRED} "${FILE}" "${FILE}"
        NAME=$( echo "${FILE}" | cut -c 3- )
        echo "File '${NAME}' converted to '${DESIRED}' quality."
      fi

    done
