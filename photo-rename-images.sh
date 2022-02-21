#! /bin/sh

jhead -n%Y.%m.%d.%H%M *.[jJ][pP][gG]     2> /dev/null
jhead -n%Y.%m.%d.%H%M *.[jJ][pP][eE]     2> /dev/null
jhead -n%Y.%m.%d.%H%M *.[jJ][pP][eE][gG] 2> /dev/null

echo '1' 2> /dev/null >> ~/scripts/stats/${0##*/}
