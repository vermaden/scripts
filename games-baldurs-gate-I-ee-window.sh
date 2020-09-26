cd ~/.wine/drive_c/BG1EE
wine explorer /desktop=name,800x600 Baldur.exe
xrandr -s 0

echo '1' >> ~/scripts/stats/${0##*/}
