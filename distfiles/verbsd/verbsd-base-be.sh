#! /bin/sh

# LOAD SETTINGS
if [ -f ./verbsd-settings.sh ]
then
  . ./verbsd-settings.sh
else
  echo "NOPE: the 'verbsd-settings.sh' is not available"
  exit 1
fi

# ASK USER FOR DESRUPTIVE ACTIONS
echo    "INFO: destroy '${POOL}/ROOT/${BE}' along with clones and create new BE there"
echo -n "READ: are you OK with that? (y/n): "
read YESNO

# CHECK YES/NO ANSWER AND ACT ACCORDINGLY
case ${YESNO} in
  (y|yes|ok) : ;;
  (*)        __error "user did not wanted to continue"
esac

# DESTROY EXISTING ZFS BE
echo "INFO: trying to destroy '${POOL}/ROOT/${BE}' BE"
zfs destroy -R -f -r "${POOL}/ROOT/${BE}" 2> /dev/null
echo "INFO: BE '${POOL}/ROOT/${BE}' destroyed"

# CREATE NEW ZFS BE
echo "INFO: trying to create new '${POOL}/ROOT/${BE}' BE"
zfs create -o mountpoint=/ -o canmount=off "${POOL}/ROOT/${BE}" \
  || __error "could not create '${POOL}/ROOT/${BE}' env"
echo "INFO: new BE '${POOL}/ROOT/${BE}' created"

# INSTALL beadm(8) MANAGER
echo "INFO: trying to install 'beadm' package"
/usr/bin/env ASSUME_ALWAYS_YES=yes pkg install -y beadm 1> /dev/null 2> /dev/null \
  || __error "could not install 'beadm' package"
echo "INFO: package 'beadm' installed"

# MOUNT NEW BE
echo "INFO: trying to mount '${BE}' BE on '${BEDIR}' dir"
beadm mount "${BE}" "${BEDIR}" 1> /dev/null 2> /dev/null
echo "INFO: BE '${BE}' mounted on '${BEDIR}' dir"
