cd ~/.wine/drive_c/Lionheart
wine explorer /desktop=name,800x600 Lionheart.exe
xrandr -s 0

echo '1' >> ~/scripts/stats/${0##*/}
