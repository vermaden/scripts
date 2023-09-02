# IMPORT DOAS/SUDO
  if [ -f ~/.zshrc.DOAS.SUDO ]
  then
    source ~/.zshrc.DOAS.SUDO
  else
    echo "NOPE: file ~/.zshrc.DOAS.SUDO absent."
  fi

# BASICS
  export PATH=${PATH}:~/scripts:~/scripts/bin:~/.cargo/bin
  export EDITOR=vi
  export VISUAL=vi
  export BROWSER=firefox
  export MANWIDTH=tty
  export ENV=${HOME}/.shrc
  export IFCONFIG_FORMAT=inet:cidr
  export LC_COLLATE=C

# BASICS DESKTOP
  export DISPLAY=:0
  export MOZ_DISABLE_IMAGE_OPTIMIZE=1
  export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on'
  export NO_AT_BRIDGE=1

# ENABLE ICONS IN exa(1)
  case ${TERM} in
    (rxvt)   : ;;
    (xterm*) : ;;
    (*)      alias exa='exa --icons' ;;
  esac

# ALIASES
  alias Grep=grep
  alias grpe=grep
  alias grepMAC='grep -i -E "[0-9a-f]{2}\:[0-9a-f]{2}\:[0-9a-f]{2}\:[0-9a-f]{2}\:[0-9a-f]{2}\:[0-9a-f]{2}"'
  alias grepIP='grep -E "([0-9]+\.){3}[0-9]+"'
  alias cls='printf "\033[H\033[J"'
  alias e=exa
  alias nv='nc -v'
  alias bat='bat --color=always'
  alias x='xinit ~/.xinitrc -- -dpi 75 -nolisten tcp 1> /dev/null 2> /dev/null'
  alias ffmpeg='ffmpeg -hide_banner'
  alias mupdf='mupdf -r 120'
  alias tac='tail -r'
  alias lsof='lsof -w'
  alias less='less -r --chop-long-lines'
  alias more='less -r --chop-long-lines'
  alias pstree='pstree -g 2'
  alias lupe='lupe -noshape -mag 2 -nohud -geometry 300x200 -noreticle -noiff'
  alias parallel='parallel --no-notice --progress -j 3'
  alias pv='pv -t -r -a -b -W -B 1048576'
  alias caja='caja --browser --no-desktop'
  alias evince=atril
  alias we="curl -4 http://wttr.in/Lodz\?Q\?n 2> /dev/null | sed '\$d' | sed '\$d'"
  alias cclive='cclive -c'
  alias yu='     youtube-dl -c -i -f best --skip-unavailable-fragments'
  alias yu-best='youtube-dl -c -i         --skip-unavailable-fragments'
  alias aria2c='aria2c --file-allocation=none'
  alias dig=drill
  alias duf='duf -style ascii'
  alias qr='qrencode -t ansiutf8'
  alias open=xdg-open
  alias see=see.sh
  alias bat='bat --style=plain'
  alias cssh='cssh -o "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"'
  alias ssh='ssh -C -c aes128-ctr -o LogLevel=quiet -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
  alias sshfs='sshfs -C -o max_conns=2'
  alias feh="feh --scale-down \
                 --auto-rotate \
                 --auto-zoom \
                 --fontpath ~/.fonts \
                 --font       ubuntu/8 \
                 --menu-font  ubuntu/8 \
                 --title-font ubuntu/8"
  alias wget='wget -c --no-check-certificate \
                   -U "Opera/12.16 (X11; FreeBSD 13.0 amd64; U; en) Presto/3 Version/12"'
  alias scp='scp -o ControlMaster=yes \
                 -o ControlPath=/tmp/%r@%h:%p \
                 -o UserKnownHostsFile=/dev/null \
                 -o StrictHostKeyChecking=no'

# SHORT HISTORY ALIASES h() H()
  alias h='< ~/.zhistory grep -i'
  alias H='< ~/.zhistory grep'

# SHORT GREP FUNCTIONS
  alias g='grep -i'
  alias G='grep'

# SHORT QUERY FUNCTIONS q()
  q() {
    if [ ${#} -eq 1 ]
    then
      /bin/ls | grep --color -i ${1} 2> /dev/null
    else
      echo "usage: q string"
    fi
  }

# SHORT QUERY FUNCTIONS Q()
  Q() {
    if [ ${#} -eq 1 ]
    then
      /bin/ls | grep --color ${1} 2> /dev/null
    else
      echo "usage: Q string"
    fi
  }

# SHORT QUERY FUNCTIONS qq()
  qq() {
    if [ ${#} -eq 1 ]
    then
      find . \
        | grep -i ${1} 2> /dev/null \
        | cut -c 3-999 \
        | grep --color -i ${1} 2> /dev/null
    else
      echo "usage: qq string"
    fi
  }

# SHORT QUERY FUNCTIONS QQ()
  QQ() {
    if [ ${#} -eq 1 ]
    then
      find . \
        | grep ${1} 2> /dev/null \
        | cut -c 3-999 \
        | grep --color ${1} 2> /dev/null
    else
      echo "usage: QQ string"
    fi
  }

# FUNTIONS / INTELIGENT CD()
  dc() {
    if [ -f "${@}" ]
    then
      cd "${@%/*}"
      return 0
    fi

    if [ -d "${@}" ]
    then
      cd "${@}"
      return 0
    fi

    echo "${0}: no such file or directory: ${@}"
    return 1
  }

# FUNTIONS / PORTS / ports-check()
  ports-check() {
    CUT='Major OS version upgrade detected.'
    ${CMD} nice -n 20 gitup ports
    echo
    ${CMD} nice -n 20 portmaster -L --index-only \
      | grep -v "${CUT}" \
      | awk '/ [Nn]ew / { print substr($0,9,9999) }'
    echo
    VULNS=$( ${CMD} pkg audit -F 2>&1 | grep ' vulnerable' | sort -u | sed 's/\ is\ vulnerable://g' )
    echo Vulnerabilities:
    if [ "${VULNS}" = "" ]
    then
      echo None.
    else
      echo "${VULNS}"
    fi
    echo
    pkg updating \
      -d $( date -j -f "%s" "$( pkg query -a %t | grep -v "${CUT}" | sort | tail -1 )" "+%Y%m%d" )
  }

# FUNTIONS / PORTS / ports-rebuild()
  ports-rebuild() {
    # OPTIONS
    local PORTS='multimedia/ffmpeg'
  # local PORTS='multimedia/ffmpeg audio/lame sysutils/exfat-utils sysutils/fusefs-exfat'

    for PORT in ${PORTS}
    do
      ${CMD} pkg unlock -y ${PORT} 1> /dev/null 2> /dev/null
      ${CMD} idprio 10 env BATCH=yes DISABLE_VULNERABILITIES=yes make -C /usr/ports/${PORT} build deinstall install clean &
      MAKE=${!}
      ${CMD} rctl -a process:${MAKE}:pcpu:deny=40
      ${CMD} wait ${MAKE}
      ${CMD} pkg lock -y ${PORT}
    done
  }

# FUNTIONS / PORTS / ports-build()
  ports-build() {
    case ${#} in
      (0) ${CMD} nice -n 20 portmaster -y --no-confirm -m 'BATCH=yes' -d -a ;;
      (*) ${CMD} nice -n 20 portmaster -y --no-confirm -m 'BATCH=yes' -d $@ ;;
    esac
    ${CMD} nice -n 20 find /var/db/pkg -type d -depth 1 -exec rm -rf {} ';' 2> /dev/null
  }

# FUNTIONS / PKG / pkg-defunct()
  pkg-defunct() {
    pkg version -Rl\? | cut -wf1
  }

# FUNTIONS / PORTS / pkg-version()
  pkg-version() {
    pkg version -I -l '<' | awk '{print $1}'
  }

# FUNTIONS / PORTS / pkg-size()
  pkg-size() {
    pkg info -as | sort -k 2 -h | tail -100
  }

# FUNCTIONS / PORTS / ports()
  ports() {
    pkg search -o "${@}" \
      | awk '{print $1}' \
      | sort -n \
      | grep -i "${@}"
  }

# FUNTIONS / BMI
  bmi() { # 1=HEIGHT 2=WEIGHT
    if [ ${#} -ne 2 ]
    then
      echo "usage: ${0##*/} HEIGHT WEIGHT"
      echo
      echo "table:"
      echo "  UNDER WEIGHT   LESS - 18.4"
      echo "  NORMAL WEIGHT  18.5 - 24.9"
      echo "  OVER WEIGHT    25.0 - 29.9"
      echo "  OBESITY        30.0 - MORE"
      echo
      return 1
    fi
    local BMI=$( echo "${2} / ( ${1} * ${1} ) * 10000" | bc -l )
    printf "%.1f\n" "${BMI}"
  }

# FUNTIONS / BFP
  bfp() {
    if [ ${#} -ne 4 ]
    then
      echo "usage: ${0##*/} HEIGHT WEIGHT AGE SEX"
      echo
      echo "SEX: f - female"
      echo "     m - male"
      return 1
    fi
    case ${4} in
      (m) SEX=1 ;;
      (f) SEX=0 ;;
    esac
    local BMI=$( echo "${2} / ( ${1} * ${1} ) * 10000" | bc -l )
    local BFP=$( echo "( 1.2 * ${BMI} ) + ( 0.23 * ${3} ) - ( 10.8 * ${SEX} ) - 5.4" | bc -l )
    printf "%.1f%%\n" "${BFP}"
  }

# FUNTIONS / MATH
  math() {
    local SCALE=2
    local INPUT=$( echo "${@}" | tr 'x' '*' | tr ',' '.' )
    local RESULT=$( echo "scale=${SCALE}; ${INPUT}" | bc -l )
    if echo ${RESULT} | grep -q '^\.'
    then
      echo -n 0
    fi
    echo ${RESULT}
  }

# FUNTIONS / MAH2WH
  conv_mah_2_wh() {
    if [ ${#} -ne 2 ]
    then
      echo "usage: ${0##*/} mAh V"
      echo
      return 1
    fi
    local MAH2WH=$( echo "${1} * ${2} / 1000" | bc -l )
    printf "%.1f Wh\n" "${MAH2WH}"
  }

# FUNTIONS / WH2MAH
  conv_wh_2_mah() {
    if [ ${#} -ne 2 ]
    then
      echo "usage: $${0##*/} Wh V"
      echo
      return 1
    fi
    local WH2MAH=$( echo "${1} / ${2} * 1000" | bc -l )
    printf "%.1f mAh\n" "${WH2MAH}"
  }

# FUNTIONS / CM2IN
  conv_cm_2_in() {
    if [ ${#} -ne 1 ]
    then
      echo "usage: ${0##*/} INCH"
      echo
      return 1
    fi
    local CM=$( echo "${1} / 2.54" | bc -l )
    printf "%.1f cm EQUALS %.1f inch(es)\n" "${1}" "${CM}"
  }

# FUNTIONS / IN2CM
  conv_in_2_cm() {
    if [ ${#} -ne 1 ]
    then
      echo "usage: ${0##*/} INCH"
      echo
      return 1
    fi
    local INCH=$( echo "${1} * 2.54" | bc -l )
    printf "%.1f inch(es) EQUALS %.1f cm\n" "${1}" "${INCH}"
  }

# FUNCTIONS / MI2KM
  conv_mi_2_km() {
    if [ ${#} -ne 1 ]
    then
      echo "usage: ${0##*/} MILES"
      echo
      return 1
    fi
    local KM=$( echo "${1} * 1.609344" | bc -l )
    printf "%.1f mile(s) EQUALS %.1f kilometer(s)\n" "${1}" "${KM}"
  }

# FUNCTIONS / KM2MI
  conv_km_2_mi() {
    if [ ${#} -ne 1 ]
    then
      echo "usage: ${0##*/} KILOMETERS"
      echo
      return 1
    fi
    local MI=$( echo "${1} / 1.609344" | bc -l )
    printf "%.1f kilometer(s) EQUALS %.1f mile(s)\n" "${1}" "${MI}"
  }

# FUNTIONS / REMOVE SSH known_hosts KEY
  ssh_known_hosts_key_remove() {
    if [[ -z "${1}" ]]
    then
      echo "usage: ${0} <host>"
      echo "  Removes specified host from ~/.ssh/known_hosts file."
    else
      sed -i '' -e "/${1}/d" ${HOME}/.ssh/known_hosts
    fi
  }

# FUNTIONS / CAL
  cal() {
    if which gcal 1> /dev/null 2> /dev/null
    then
      local TEST="${@}"
      if [ "${TEST}" = "-3" ]
      then
        gcal -s 1 .  | sed 1,2d | sed 3d
      else
        gcal -s 1 ${@}
      fi
    else
      cal ${@}
    fi
  }

# FUNTIONS / DAY
  day() {
    if [ ${#} -eq 0 ]
    then
      echo "usage: ${0##*/} DAY-OF-MONTH"
      return 1
    fi
    cal $( date +%Y ) \
      | env GREP_COLOR="07;32" grep --color=always -EC 6 " $1 |^$1 | $1\$" \
      | env GREP_COLOR="07;33" grep --color=always -B2 -A6 -E 'Mo|Tu|We|Th|Fr|Sa|Su' \
      | grep -v -- --;
  }

# FUNTIONS / BMR
  bmr() {
    if [ ${#} -ne 3 ]
    then
      echo "usage: ${0##*/} WIEGHT HEIGHT AGE"
      echo
      return 1
    fi
    local RESULT=$( echo "( 10 * ${1} ) + ( 6.25 * ${2} ) - ( 5 * ${3} ) + 5" | bc -l )
    if echo ${RESULT} | grep -q '^\.'
    then
      echo -n 0
    fi
    echo ${RESULT} | awk -F '.' '{print $1}'
  }

# FUNTIONS / SSH-COPY-ID
  if ! which ssh-copy-id 1> /dev/null 2> /dev/null
  then
    ssh-copy-id() {
      echo 'INFO: ssh-copy-id(1) is not available'
      echo 'HINT: cat ~/.ssh/id_rsa.pub | ssh USER@HOST "cat >> ~/.ssh/authorized_keys"'
    }
  fi

# ADDITIONAL COMPLETIONS
  if [ -e /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]
  then
    source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  fi

  if [ -e /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]
  then
    source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  fi

