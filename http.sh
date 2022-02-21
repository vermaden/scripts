#! /bin/sh

if [ ${#} -ne 1 ]
then
  echo "usage: ${0##*/} PORT"
  exit 1
fi

# python2 -m SimpleHTTPServer ${1}
python3 -m http.server ${1}

echo '1' 2> /dev/null >> ~/scripts/stats/${0##*/}
