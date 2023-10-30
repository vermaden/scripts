#! /bin/sh

cd "$( echo ${NAUTILUS_SCRIPT_CURRENT_URI} | sed -E s/'[a-z]+:\/\/'//g -e s/%20/\ /g )" && xterm -geometry 160x40 -e ncdu
