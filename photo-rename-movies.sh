#! /bin/sh

NUMBER=96

for EXTENSIONS in MP4 mkv
do
  COUNT="-1"
  COUNT=$( ls *.${EXTENSIONS} 2> /dev/null | wc -l | tr -d ' ' )
  if [ "${COUNT}" = "0" ]
  then
    COUNT="-1"
    continue
  fi

  for FILE in *.${EXTENSIONS}
  do
    SHORT=$( echo "${FILE}" | awk -F '.' '{print $1}' )
    EXT=$( echo "${FILE}" | sed 's/.*\.//' )
  # UNHASH FOR DEBUG
  # echo "FILE: ${FILE}"
  # echo "SHORT: ${SHORT}"
  # echo "EXT: ${EXT}"
    for TRY in ${SHORT}M01.XML \
               ${SHORT}m01.xml \
               ${SHORT}.XML    \
               ${SHORT}.xml
    do
      if [ -f "${TRY}" ]
      then
      # UNHASH FOR DEBUG
      # echo "TRY: ${TRY}"
      # 2017-01-29T18:00:08Z
        NEW=$( cat ${TRY} | grep CreationDate )
        NEW=$( echo ${NEW} | awk -F '"' '{print $2}' )
        NEW=$( echo ${NEW} | awk -F 'T' '{print $1}' )
        NEW=$( echo ${NEW} | tr '-' '.' )
        NEWTIME=$( cat ${TRY} | grep CreationDate )
        NEWTIME=$( echo ${NEWTIME} | awk -F '"' '{print $2}' )
        NEWTIME=$( echo ${NEWTIME} | awk -F 'T' '{print $2}' )
        NEWTIME=$( echo ${NEWTIME} | awk -F ':' '{print $1 "" $2}' )
      # UNHASH FOR DEBUG
      # echo NEW: ${NEW}
      # echo NEWTIME: ${NEWTIME}
      # echo PREVIOUS: ${PREVIOUS}
        if [ "${NEW}.${NEWTIME}" != "${PREVIOUS}" ]
        then
          NUMBER=96
          PREFIX=0
        else
          PREFIX=1
          NUMBER=$(( ${NUMBER} + 1 ))
        fi
        PRINTABLE=$( printf "\\$(printf %o ${NUMBER})\n" )
        case ${PREFIX} in
          (0)
            mv -v "${FILE}" "${NEW}.${NEWTIME}.${EXT}"
            mv -v "${TRY}"  "${NEW}.${NEWTIME}.XML"
            ;;
          (1)
            mv -v "${FILE}" "${NEW}.${NEWTIME}${PRINTABLE}.${EXT}"
            mv -v "${TRY}"  "${NEW}.${NEWTIME}${PRINTABLE}.XML"
            ;;
        esac
        PREVIOUS="${NEW}.${NEWTIME}"
        break
      fi
    done
  done
done
