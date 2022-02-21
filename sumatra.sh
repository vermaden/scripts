#! /bin/sh

if [ ${#} -eq 0 ]
then
  echo "usage: ${0##*/} FILE"
  echo
  exit 1
fi

WINE=none

if which wine 1> /dev/null 2> /dev/null
then
  WINE=wine
fi

if [ "${WINE}" != "none" ]
then
  wine ~/win32/bin/sumatrapdf.exe "${@}" &
else
  if which zenity 1> /dev/null 2> /dev/null
  then
    zenity --title 'Sumatra PDF' --info --text 'WINE not available in \${PATH}.\n\nInstall WINE.'
  fi
fi

echo '1' 2> /dev/null >> ~/scripts/stats/${0##*/}

