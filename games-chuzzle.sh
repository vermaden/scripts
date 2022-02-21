cd ~/games.EXTRACT/chuzzle
wine chuzzle.exe
xrandr -s 0

echo '1' 2> /dev/null >> ~/scripts/stats/${0##*/}
