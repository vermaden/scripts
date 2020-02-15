#! /bin/sh

__usage() {
  echo "usage: ${0##*/} DIR DIR"
  echo "       ${0##*/} DIR [[USER@]SERVER:]DIR"
  echo "       ${0##*/} [[USER@]SERVER:]DIR DIR"
  echo
  echo "examples: ${0##*/} backup user@host:remote"
  echo "          ${0##*/} backup /storage/backup"
  echo
  exit 1
}

__slash() {
  [ $( echo "${@}" | grep -o -E ".$" ) = / ] && echo "${@}" || echo "${@}/"
}

case ${#} in
  (2)
    which rsync 1> /dev/null 2> /dev/null || {
      echo "ER: rsync not in \${PATH}"
      echo
      exit 1
    }
    echo "${1}" | grep : 1> /dev/null 2> /dev/null && SSH='-e "ssh -C"'
    echo "${2}" | grep : 1> /dev/null 2> /dev/null && SSH='-e "ssh -C"'
    eval rsync ${SSH} --modify-window=1 -l -t -r -D -v -S -H \
                      --force --progress --rsync-path=/usr/local/bin/rsync \
                      --no-whole-file --numeric-ids \
                      --delete-before \
                      --exclude=.cache \
                      "$( __slash ${1} )" "$( __slash ${2} )"
                      # --inplace
    ;;

  (*)
    __usage
    ;;
esac

# --archive --hard-links --sparse --xattrs --numeric-ids

echo '1' >> ~/scripts/stats/${0##*/}
