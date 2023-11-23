#! /bin/sh

# LOAD SETTINGS
if [ -f ./verbsd-settings.sh ]
then
  . ./verbsd-settings.sh
else
  echo "NOPE: the 'verbsd-settings.sh' is not available"
  exit 1
fi

# CREATE USER
echo "INFO: trying to create the '${THEUSER}' user"
chroot "${BEDIR}" \
  /usr/bin/env pw userdel -n ${THEUSER} -r 1> /dev/null 2> /dev/null
chroot "${BEDIR}" \
  /usr/bin/env pw useradd ${THEUSER} \
    -c ${THEUSER} \
    -u ${THEUSERUID} \
    -d ${THEUSERDIR} \
    -G ${THEUSERGRP} \
    -s /usr/local/bin/zsh \
      || __error "could not create '${THEUSER}' user"
echo "INFO: user '${THEUSER}' created"

# TODO
# passwd root
# passwd vermaden
