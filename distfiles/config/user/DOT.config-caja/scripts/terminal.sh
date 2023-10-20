#! /bin/sh

cd "$( echo ${NAUTILUS_SCRIPT_CURRENT_URI} | sed -E -e s/'[a-z]+:\/\/'//g -e s/'%20'/\ /g -e s/'%5B'/\[/g -e s/'%5D'/\]/g  )" && xterm

