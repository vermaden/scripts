#! /bin/sh

WINE=none

if which wine 1> /dev/null 2> /dev/null
then
  WINE=wine
fi

if [ "${WINE}" != "none" ]
then
  wine ~/win32/bin/xnview-2.37xnview.exe &
else
  if which zenity 1> /dev/null 2> /dev/null
  then
    zenity --title 'XnView' --info --text 'WINE not available in \${PATH}.\n\nInstall WINE.'
  fi
fi
