#! /bin/sh

# LOAD SETTINGS
if [ -f ./verbsd-settings.sh ]
then
  . ./verbsd-settings.sh
else
  echo "NOPE: the 'verbsd-settings.sh' is not available"
  exit 1
fi

# CREATE BASE DIR WHERE DIST FILES WOULD BE FETCHED
echo "INFO: trying to create '/jail/BASE' dir"
mkdir -p "${BASEDIR}" || __error "could not create '/jail/BASE' dir"
echo "INFO: dir '/jail/BASE' created"

# FETCH DIST FILES
echo "INFO: trying to fetch DIST files"
for DIST in ${DISTLIST}
do
  if [ ! -f "${BASEDIR}/${VER}-${ARCH}-${DIST}.txz" ]
  then
    fetch -o "${BASEDIR}/${VER}-${ARCH}-${DIST}.txz" "${LINK}/${DIST}.txz" \
      || __error "could not fetch '${VER}-${ARCH}-${DIST}.txz' file"
  else
    echo "INFO: the DIST file '${VER}-${ARCH}-${DIST}.txz' already fetched"
  fi
done
echo "INFO: the DISK files are fetched"

# FETCH MANICEST FILE WITH CHECKSUMS
echo "INFO: trying to fetch MANIFEST file"
if [ ! -f "${BASEDIR}/${VER}-${ARCH}-MANIFEST" ]
then
  fetch -o "${BASEDIR}/${VER}-${ARCH}-MANIFEST" "${LINK}/MANIFEST" \
    || __error "could not fetch '${VER}-${ARCH}-MANIFEST' file"
else
  echo "INFO: the MANIFEST file already fetched"
fi
echo "INFO: the MANIFEST file fetched"

# CHECK IF MANIFEST EXISTS
[ -f "${BASEDIR}/${VER}-${ARCH}-MANIFEST" ] \
  || __error "the '${VER}-${ARCH}-MANIFEST' does not exists"

# VERIFY CHECKSUMS
echo "INFO: trying to verify checksums against MANIFEST file"
MANIDATA=$( cat "${BASEDIR}/${VER}-${ARCH}-MANIFEST" )
for I in ${DISTLIST}
do
  echo "INFO: trying to verify checksum for '${VER}-${ARCH}-${I}.txz' DIST file"
  [ -f "${BASEDIR}/${VER}-${ARCH}-${I}.txz" ] \
    || __error "file '${BASEDIR}/${VER}-${ARCH}-${I}.txz' does not exists"

  MANISUM=$( echo "${MANIDATA}" | grep "${I}.txz" | awk '{print $2}' )
  SHASUM=$( sha256 "${BASEDIR}/${VER}-${ARCH}-${I}.txz" | awk '{print $NF}' )
  [ "${MANISUM}" = "${SHASUM}" ] \
    || __error "checksum for '${BASEDIR}/${VER}-${ARCH}-${I}.txz' file does not match"
  echo "INFO: checksum for '${VER}-${ARCH}-${I}.txz' DIST file verified"
done
echo "INFO: checksums against MANIFEST file verified successfully"
