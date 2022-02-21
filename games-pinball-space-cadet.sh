cd "~/.wine/drive_c/Pinball Space Cadet"
wine pinball.exe
xrandr -s 0

echo '1' 2> /dev/null >> ~/scripts/stats/${0##*/}
