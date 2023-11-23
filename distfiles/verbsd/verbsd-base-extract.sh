#! /bin/sh

# LOAD SETTINGS
if [ -f ./verbsd-settings.sh ]
then
  . ./verbsd-settings.sh
else
  echo "NOPE: the 'verbsd-settings.sh' is not available"
  exit 1
fi

echo "INFO: trying to extract DIST files"
# EXTRACT DIST FILES
for DIST in ${DISTLIST}
do
  echo "INFO: trying to extract '${VER}-${ARCH}-${DIST}.txz' file"
  tar -C "${BEDIR}" --unlink -xpf "${BASEDIR}/${VER}-${ARCH}-${DIST}.txz" \
    || __error "could not extract '${VER}-${ARCH}-${DIST}.txz' file"
  echo "INFO: the '${VER}-${ARCH}-${DIST}.txz' file extracted"
done
echo "INFO: DIST files extracted"
