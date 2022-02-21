cd ~/.dosbox/
dosbox -ioctl -conf ~/.dosbox/swing.cfg

echo '1' 2> /dev/null >> ~/scripts/stats/${0##*/}
