#! /bin/sh

if [ ${#} -ne 1 ]
then
  echo "usage: ${0##*/} PORT"
  exit 1
fi

if which -s python3 1> /dev/null 2> /dev/null
then
  python3 -m http.server ${1}
  exit 0
fi

if which -s python2 1> /dev/null 2> /dev/null
then
  python2 -m SimpleHTTPServer ${1}
  exit 0
fi

echo "NOPE: either 'python2' or 'python3' found in \${PATH}"
exit 1

