#! /bin/sh

jhead -n%Y.%m.%d.%H%M.%S *.[jJ][pP][gG]     2> /dev/null
jhead -n%Y.%m.%d.%H%M.%S *.[jJ][pP][eE]     2> /dev/null
jhead -n%Y.%m.%d.%H%M.%S *.[jJ][pP][eE][gG] 2> /dev/null
