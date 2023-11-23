#! /bin/sh

# LOAD SETTINGS
if [ -f ./verbsd-settings.sh ]
then
  . ./verbsd-settings.sh
else
  echo "NOPE: the 'verbsd-settings.sh' is not available"
  exit 1
fi

echo "INFO: trying to set DNS to 1.1.1.1"
[ "${BEDIR}" != "" ] || __error "the 'BEDIR' variable is empty"
echo 'nameserver 1.1.1.1' > "${BEDIR}"/etc/resolv.conf \
  || __error "failed to set DNS to 1.1.1.1"
echo "INFO: DNS successfully set to 1.1.1.1"

echo "INFO: try to switch to 'latest' pkg(8) branch"
mkdir -p "${BEDIR}"/usr/local/etc/pkg/repos \
  || __error "could not create '${BEDIR}/usr/local/etc/pkg/repos' dir"
sed s-quarterly-latest-g "${BEDIR}"/etc/pkg/FreeBSD.conf \
  > "${BEDIR}"/usr/local/etc/pkg/repos/FreeBSD.conf \
  || __error "could not switch to 'latest' branch in '${BEDIR}/usr/local/etc/pkg/repos/FreeBSD.conf' file"
echo "INFO: switched to 'latest' pkg(8) branch successfully"

# BUG: https://github.com/freebsd/pkg/issues/2195
echo "INFO: trying to install specified pkg(8) packages"
mount -t devfs devfs "${BEDIR}"/dev \
  || _error "could not mount devfs(8) on '${BEDIR}/dev' dir"
while read EXCLUDE
do
  [ "${EXCLUDE}" = "" ] && break
  echo "INFO: excluding '${EXCLUDE}' from pkg(8) packages (not available)"
  PACKAGES=$( echo ${PACKAGES} | sed s.${EXCLUDE}..g )
done << EOF
$(
  chroot "${BEDIR}" \
    /usr/bin/env ASSUME_ALWAYS_YES=yes pkg install -y --ignore-missing ${PACKAGES} 2>&1 \
      | grep "No packages available to install matching" \
      | awk -F\' '{print $2}'
)
EOF
chroot "${BEDIR}" \
  /usr/bin/env ASSUME_ALWAYS_YES=yes pkg install -y --ignore-missing ${PACKAGES} \
  || __error "could not install specified pkg(8) packages"
umount -f "${BEDIR}"/dev \
  || _error "could not umount(8) the devfs(8) on '${BEDIR}/dev' dir"
echo "INFO: specified pkg(8) packages installed successfully"
