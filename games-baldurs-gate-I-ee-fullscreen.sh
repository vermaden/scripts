cd ~/.wine/drive_c/BG1EE
wine Baldur.exe
xrandr -s 0

echo '1' 2> /dev/null >> ~/scripts/stats/${0##*/}
