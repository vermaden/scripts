#! /bin/sh

if [ ! -f /usr/local/etc/rc.d/powerdxx ]
then
  echo "NOPE: please install 'sysutils/powerdxx' daemon"
  exit 1
fi

doas service powerd   onestop  1> /dev/null 2> /dev/null
doas service powerdxx onestart 1> /dev/null 2> /dev/null

# DETAILS IN hwpstate_intel(4) MAN PAGE
doas sysctl dev.hwpstate_intel.0.epp=100  2> /dev/null
doas sysctl dev.hwpstate_intel.1.epp=100  2> /dev/null
doas sysctl dev.hwpstate_intel.2.epp=100  2> /dev/null
doas sysctl dev.hwpstate_intel.3.epp=100  2> /dev/null
doas sysctl dev.hwpstate_intel.4.epp=100  2> /dev/null
doas sysctl dev.hwpstate_intel.5.epp=100  2> /dev/null
doas sysctl dev.hwpstate_intel.6.epp=100  2> /dev/null
doas sysctl dev.hwpstate_intel.7.epp=100  2> /dev/null
doas sysctl dev.hwpstate_intel.8.epp=100  2> /dev/null
doas sysctl dev.hwpstate_intel.9.epp=100  2> /dev/null
doas sysctl dev.hwpstate_intel.10.epp=100 2> /dev/null
doas sysctl dev.hwpstate_intel.11.epp=100 2> /dev/null
doas sysctl dev.hwpstate_intel.12.epp=100 2> /dev/null
doas sysctl dev.hwpstate_intel.13.epp=100 2> /dev/null
doas sysctl dev.hwpstate_intel.14.epp=100 2> /dev/null
doas sysctl dev.hwpstate_intel.15.epp=100 2> /dev/null
doas sysctl dev.hwpstate_intel.16.epp=100 2> /dev/null
doas sysctl dev.hwpstate_intel.17.epp=100 2> /dev/null
doas sysctl dev.hwpstate_intel.18.epp=100 2> /dev/null
doas sysctl dev.hwpstate_intel.19.epp=100 2> /dev/null
doas sysctl dev.hwpstate_intel.20.epp=100 2> /dev/null
doas sysctl dev.hwpstate_intel.21.epp=100 2> /dev/null
doas sysctl dev.hwpstate_intel.22.epp=100 2> /dev/null
doas sysctl dev.hwpstate_intel.23.epp=100 2> /dev/null
doas sysctl dev.hwpstate_intel.24.epp=100 2> /dev/null
doas sysctl dev.hwpstate_intel.25.epp=100 2> /dev/null
doas sysctl dev.hwpstate_intel.26.epp=100 2> /dev/null
doas sysctl dev.hwpstate_intel.27.epp=100 2> /dev/null
doas sysctl dev.hwpstate_intel.28.epp=100 2> /dev/null
doas sysctl dev.hwpstate_intel.29.epp=100 2> /dev/null
doas sysctl dev.hwpstate_intel.30.epp=100 2> /dev/null
doas sysctl dev.hwpstate_intel.31.epp=100 2> /dev/null
