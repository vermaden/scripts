#! /bin/sh

# WAIT 5 SECONDS WITH -t OPTION
if ! ping -c 1 -s 0 -t 5 -q 1.1.1.1 1> /dev/null 2> /dev/null
then
  ~/scripts/network.sh wlan start
else
  exit 0
fi

~/scripts/network-ping.sh

