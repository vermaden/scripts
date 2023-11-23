#! /bin/sh

# LOAD SETTINGS
if [ -f ./verbsd-settings.sh ]
then
  . ./verbsd-settings.sh
else
  echo "NOPE: the 'verbsd-settings.sh' is not available"
  exit 1
fi

# INSTALL git(1) MANAGER
echo "INFO: trying to install 'git' package"
/usr/bin/env ASSUME_ALWAYS_YES=yes pkg install -y git 1> /dev/null 2> /dev/null \
  || __error "could not install 'git' package"
echo "INFO: package 'git' installed"

# CLEAN ./scripts' DIR
echo "INFO: trying to remove './scripts' dir"
rm -rf ./scripts || __error "could not remove './scripts' dir"
echo "INFO: the './scripts' dir removed"

# CLONE ./scripts' DIR
echo "INFO: trying to clone 'https://github.com/vermaden/scripts' repo"
git --git-dir=/dev/null clone --depth 1 https://github.com/vermaden/scripts \
  || __error "could not clone 'https://github.com/vermaden/scripts' repo"
echo "INFO: repo 'https://github.com/vermaden/scripts' cloned"
