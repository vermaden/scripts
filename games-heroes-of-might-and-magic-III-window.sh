cd ~/.wine/drive_c/HoMM3
wine explorer /desktop=name,800x600 heroes3.exe
xrandr -s 0

echo '1' 2> /dev/null >> ~/scripts/stats/${0##*/}
