cd ~/.wine/drive_c/IWDEE
wine explorer /desktop=name,800x600 Icewind.exe
xrandr -s 0

echo '1' 2> /dev/null >> ~/scripts/stats/${0##*/}

