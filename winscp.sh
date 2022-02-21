#! /bin/sh

WINE=none

if which wine 1> /dev/null 2> /dev/null
then
  WINE=wine
fi

if [ "${WINE}" != "none" ]
then
  wine ~/win32/bin/winscp.exe &
else
  if which zenity 1> /dev/null 2> /dev/null
  then
    zenity --title 'WinSCP' --info --text 'WINE not available in \${PATH}.\n\nInstall WINE.'
  fi
fi

echo '1' 2> /dev/null >> ~/scripts/stats/${0##*/}

