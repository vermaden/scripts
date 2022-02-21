cd ~/.wine/drive_c/Timeshock
wine explorer /desktop=name,800x600 Timeshock\!.exe
xrandr -s 0

echo '1' 2> /dev/null >> ~/scripts/stats/${0##*/}
