#! /bin/sh

thunar "$( echo ${NAUTILUS_SCRIPT_CURRENT_URI} | sed -E s/'[a-z]+:\/\/'//g -E s/'%20'/\ /g )"
