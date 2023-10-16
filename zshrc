# BASICS
  umask 022
  export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
  export EDITOR=vi
  export PAGER=less
  export LC_COLLATE=C

# USE ftp(1) PASSIVE MODE
  export FTP_PASSIVE_MODE=1

# DISABLE less(1) HISTORY
  export LESSHISTSIZE=0

# IMITATE sockstat(1) ON LINUX
  case $( uname ) in
    (Linux) alias sockstat="netstat -lnptu --protocol=inet,unix" ;;
  esac

# ZSH HISTORY
  export HISTSIZE=655360
  export HISTFILE="${HOME}/.zhistory"
  export SAVEHIST=${HISTSIZE}

# ZSH HISTORY SEARCH
# bindkey -M vicmd '/' history-incremental-pattern-search-backward
# bindkey -M vicmd '?' history-incremental-pattern-search-forward

# ZSH HISTORY SEARCH [CTRL]-[R] AND [CTRL]-[F] FOR vi(1) INSERT MODE
  bindkey -M viins '^R' history-incremental-pattern-search-backward
  bindkey -M viins '^F' history-incremental-pattern-search-forward

# ZSH HISTORY MAPPINGS
  bindkey '^[[A' up-line-or-search
  bindkey '^[[B' down-line-or-search
  bindkey "^R" history-incremental-search-backward

# ZSH USE [SHIFT]-[TAB] FOR REVERSE COMPLETION
  bindkey '^[[Z' reverse-menu-complete

# ZSH LAST ARG FROM EARLIER COMMAND WITH [ALT]-[.] KEYS
  bindkey '\e.' insert-last-word

# ZSH BEGIN/END OF LINE WITH [CTRL]-[A] AND [CTRL]-[END] KEYS
  bindkey "^A" beginning-of-line
  bindkey "^E" end-of-line

# KEY BINDINGS
  case "${TERM}" in
    (cons25*|linux)
      # PLAIN BSD/LINUX CONSOLE
      bindkey '\e[H'    beginning-of-line   # HOME
      bindkey '\e[F'    end-of-line         # END
      bindkey '\e[5~'   delete-char         # DELETE
      bindkey '[D'      emacs-backward-word # ESC <
      bindkey '[C'      emacs-forward-word  # ESC >
      ;;
    (*rxvt*)
      # RXVT DERIVATIVES
      bindkey '\e[3~'   delete-char         # DELETE
      bindkey '\eOc'    forward-word        # CTRL >
      bindkey '\eOd'    backward-word       # CTRL <
      # RXVT WORKAROUND FOR screen(1) UNDER urxvt(1)
      bindkey '\e[7~'   beginning-of-line   # HOME
      bindkey '\e[8~'   end-of-line         # END
      bindkey '^[[1~'   beginning-of-line   # HOME
      bindkey '^[[4~'   end-of-line         # END
      ;;
    (*xterm*)
      # XTERM DERIVATIVES
      bindkey '\e[H'    beginning-of-line   # HOME
      bindkey '\e[F'    end-of-line         # END
      bindkey '\e[3~'   delete-char         # DELETE
      bindkey '\e[1;5C' forward-word        # CTRL >
      bindkey '\e[1;5D' backward-word       # CTRL <
      # XTERM WORKAROUND FOR screen(1) UNDER xterm(1)
      bindkey '\e[1~'   beginning-of-line   # HOME
      bindkey '\e[4~'   end-of-line         # END
      ;;
    (screen)
      # GNU SCREEN
      bindkey '^[[1~'   beginning-of-line   # HOME
      bindkey '^[[4~'   end-of-line         # END
      bindkey '\e[3~'   delete-char         # DELETE
      bindkey '\eOc'    forward-word        # CTRL >
      bindkey '\eOd'    backward-word       # CTRL <
      bindkey '^[[1;5C' forward-word        # CTRL >
      bindkey '^[[1;5D' backward-word       # CTRL <
      ;;
  esac

# ZSH COMPLETION CASE (IN)SENSITIVE
# zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# ZSH DISABLE USER COMPLETION FOR THESE NAMES
  zstyle ':completion:*:*:*:users' ignored-patterns \
    adm amanda apache avahi backup beaglidx bin cacti canna clamav daemon \
    dladm dbus distcache dovecot fax ftp games gdm gkrellmd gopher gnats \
    hacluster haldaemon halt hsqldb ident junkbust ldap lp irc list libuuid \
    listen mdns mail mailman mailnull mldonkey mysql man messagebus netadm \
    netcfg nagios noaccess nobody4 nuucp named netdump news nfsnobody nobody \
    nscd ntp nut nx openvpn openldap operator pcap pkg5srv postfix postgres \
    proxy privoxy pulse pvm quagga radvd rpc rpcuser rpm shutdown statd squid \
    sshd sync sys syslog uucp vcsa smmsp svctag upnp unknown webservd www-data \
    xfs xvm zfssnap '_*'

# ZSH COMPLETION OPSTIONS
  zstyle ':completion:*' completer _expand _complete _correct _approximate _history
  zstyle ':completion:*' matcher-list '' '' 'l:|=* r:|=*' 'l:|=* r:|=*'
  zstyle ':completion:*' list-colors ''
  zstyle ':completion:*' users root
  zstyle ':completion:*' menu select
  zstyle :compinstall filename '~/.zshrc'
  autoload -Uz compinit
  autoload -U colors && colors
  compinit

# ZSH OTHER FEATURES
  unsetopt beep
  setopt no_beep
  setopt nohashdirs
  setopt extended_glob
  setopt auto_cd
  setopt auto_menu
  setopt list_rows_first
  setopt multios
  setopt hist_ignore_all_dups
  setopt append_history
  setopt inc_append_history
  setopt hist_reduce_blanks
  setopt always_to_end
  setopt no_hup
  setopt complete_in_word
  limit coredumpsize 0

# ZSH zshcontrib(1) zmv
  autoload zmv
  alias zmv_to_lower='zmv      "*" "\${(L)f}"'
  alias zmv_to_upper='zmv      "*" "\${(U)f}"'
  alias zmv_to_capital='zmv    "*" "\${(C)f}"'
  alias zmv_to_hypen='zmv      "*" "\$f:gs/ /-/"'
  alias zmv_to_underscore='zmv "*" "\$f:gs/ /_/"'

# COLOR grep(1)
  export GREP_COLOR='1;32'
  export GREP_COLORS='1;32'
  export GREP_OPTIONS='--color=auto'
  alias grep='grep --color'
  alias egrep='egrep --color'

# FreeBSD ifconfig(8) CIDR NOTATION
  export IFCONFIG_FORMAT=inet:cidr

# ALIAS grep(1) IP/MAC
  alias grepMAC='grep -i -E "[0-9a-f]{2}\:[0-9a-f]{2}\:[0-9a-f]{2}\:[0-9a-f]{2}\:[0-9a-f]{2}\:[0-9a-f]{2}"'
  alias grepIP='grep -E "([0-9]+\.){3}[0-9]+"'

# SET ls(1) COLORS
  export LSCOLORS='exExcxdxcxexhxhxhxbxhx'
  export LS_COLORS='no=00:fi=00:di=00;34:ln=00;36:pi=40;33:so=00;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:mi=01;05;37;41:ex=00;32'

# DISABLE XON/XOFF FLOW CONTROL (^S/^Q)
  stty -ixon

# COLOR LIST
# 30 - black
# 31 - red
# 32 - green
# 33 - yellow
# 34 - blue
# 35 - magenta
# 36 - cyan
# 37 - white

# COLOR PROMPT
  cRND=$( env LC_ALL=C tr -c -d '0-7' < /dev/random | head -c 1 )
  case ${cRND} in
    (0) cSRV="%F{blue}"    ;; # BLACK
    (1) cSRV="%F{red}"     ;;
    (2) cSRV="%F{green}"   ;;
    (3) cSRV="%F{yellow}"  ;;
    (4) cSRV="%F{blue}"    ;;
    (5) cSRV="%F{magenta}" ;;
    (6) cSRV="%F{cyan}"    ;;
    (7) cSRV="%F{white}"   ;;
  esac
  case $( whoami ) in
    (root)
      cUSR="%F{red}"
      cPMT="%F{red}"
      ;;
    (*)
      cUSR="%F{green}%B"
      cPMT=""
      ;;
  esac
  cTIM="%F{cyan}%B"
  cPWD="%F{magenta}%B"
  cSTD="%b%f"
  export PS1="${cTIM}%T${cSTD} ${cSRV}%m${cSTD} ${cUSR}%n${cSTD} ${cPWD}%~${cSTD} ${cPMT}%#${cSTD} "
  export PS2="${cTIM}%T${cSTD} ${cUSR}>$c{STD} ${cPWD}"
# export RPS1=$'%{\e[0;34m%}%T%{\e[0m%}'

# COLOR MAN PAGES WITH less(1) OR bat(1)
  if [ -e /usr/bin/col -a -e /usr/local/bin/bat ]
  then
    # USE bat(1) AND col(1) IF AVAILABLE
    export MANPAGER="sh -c 'col -bx | bat -l man -p' "
  else
    # USE less(1) AS FALLBACK
    export LESS_TERMCAP_mb=$'\E[5m'
    export LESS_TERMCAP_md=$'\E[01;31m'
    export LESS_TERMCAP_me=$'\E[0m'
    export LESS_TERMCAP_se=$'\E[0m'
    export LESS_TERMCAP_so=$'\E[01;44;33m'
    export LESS_TERMCAP_ue=$'\E[0m'
    export LESS_TERMCAP_us=$'\E[01;32m'
  fi

# SET PROPER ENCODINGS
  case ${TERM} in
    (cons25*) export LC_ALL=en_US.ISO8859-1 ;;
    (*)       export LC_ALL=en_US.UTF-8     ;;
  esac

# ALIASES
  alias rehash='hash -r'
  alias make='env LANG=C LC_ALL=C make'
  alias vim='vim -i NONE'
  alias fetch='fetch -Rr --no-verify-peer --no-verify-hostname'
  alias wget='wget -c -t 0'

# SETUP ls(1) AND gls(1) COMMANDS
  case $( uname ) in
    (FreeBSD)
      if [ -e /usr/local/bin/gls ]
      then
        alias bls='/bin/ls -p -G -D "%Y.%m.%d %H:%M"'
        alias ls=' gls -p --color=always --time-style=long-iso --group-directories-first --quoting-style=literal'
        alias lh=' gls -p --color=always -sh'
        alias lss='gls -p --color=always -sh -S'
      else
        alias ls='/bin/ls -p -G -D "%Y.%m.%d %H:%M"'
        alias lh='ls -sh'
        alias lss='ls -sh -S'
      fi
      ;;
    (OpenBSD)
      export PKG_PATH=http://ftp.openbsd.org/pub/OpenBSD/$( uname -r )/packages/$( uname -m )/
      if [ -e /usr/local/bin/colorls ]
      then
        alias ls='/usr/local/bin/colorls -G'
      fi
      ;;
    (Linux)
      alias ls='ls -p -G --color --time-style=long-iso --group-directories-first --quoting-style=literal'
      alias lh='ls -sh'
      ;;
  esac
  alias la='ls -A'
  alias ll='ls -l'
  alias exa='exa --time-style=long-iso --group-directories-first'

# ZSH ADDITIONAL SUGGESTIONS
  if [ -e /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]
  then
    source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  fi

# ZSH ADDITIONAL fish(1) LIKE HIGHLIGHT
  if [ -e /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]
  then
    source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  fi

# SHORT (various)
  alias h=history
  alias c=clear
  alias z=zsh
  alias b=beadm
  alias o=see-pipe-open.sh
  alias s=see.sh
  alias see=see.sh
  alias i=info.sh
  alias d=caja

# SHORT HISTORY h/H ALIASES
  alias h='< ~/.zhistory grep -i'
  alias H='< ~/.zhistory grep'

# SHORT GREP g/G ALIASES
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

# FUNTIONS / PORTS / ports-fresh()
  ports-fresh() {
    ${CMD} git clone https://git.freebsd.org/ports.git /usr/ports
  }

# FUNTIONS / PORTS / ports-check()
  ports-check() {
    CUT='Major OS version upgrade detected.'

    if [ ! -e /usr/local/bin/gitup ]
    then
      echo "NOPE: install 'net/gitup' to continue"
      return 1
    fi

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
    # ${CMD} pkg lock -y ${PORT}
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

# FUNCTIONS / PORTS / pkg-repos()
  pkg-repos() {
    echo
    (
      echo "REPO PRIORITY"
      for REPO in /etc/pkg/* /usr/local/etc/pkg/repos/*
      do
        if grep -q -E 'enabled:[\ \t]*yes' "${REPO}"
        then
          awk -F ':' '/\{[\ \t]*$/ {printf("%s ",$1)}' "${REPO}"
          if grep -q priority "${REPO}"
          then
            awk '/priority:/ {print $NF}' "${REPO}"
          else
            echo 'DEFAULT'
          fi
        fi
      done
    ) | column -t
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

# FUNTIONS / L2GAL
  conv_l_2_gal() {
    if [ ${#} -ne 1 ]
    then
      echo "usage: ${0##*/} LITERS"
      echo
      return 1
    fi
    local INCH=$( echo "${1} / 4.54609" | bc -l )
    printf "%.1f litter(s) EQUALS %.1f gallon(s)\n" "${1}" "${INCH}"
  }

# FUNTIONS / GAL2L
  conv_gal_2_l() {
    if [ ${#} -ne 1 ]
    then
      echo "usage: ${0##*/} GALLONS"
      echo
      return 1
    fi
    local INCH=$( echo "${1} * 4.54609" | bc -l )
    printf "%.1f gallon(s) EQUALS %.1f litter(s)\n" "${1}" "${INCH}"
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

# FUNCTIONS / G2OZ
  conv_g_2_oz() {
    if [ ${#} -ne 1 ]
    then
      echo "usage: ${0##*/} GRAMS"
      echo
      return 1
    fi
    local G=$( echo "${1} / 28.34952" | bc -l )
    printf "%.1f gram(s) EQUALS %.1f oz(s)\n" "${1}" "${G}"
  }

# FUNCTIONS / OZ2G
  conv_oz_2_g() {
    if [ ${#} -ne 1 ]
    then
      echo "usage: ${0##*/} OZ"
      echo
      return 1
    fi
    local OZ=$( echo "${1} * 28.34952" | bc -l )
    printf "%.1f oz(s) EQUALS %.1f grams(s)\n" "${1}" "${OZ}"
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

# FUNCTIONS / color
  color() {
    if ! which -a display 1> /dev/null 2> /dev/null
    then
      echo "NOPE: please install 'graphics/ImageMagick7' package or port"
      return 1
    fi

    if [ ${#} -ne 1 ]
    then
      echo "usage:"
      echo "  $( basename ${0} ) HEX"
      echo
      echo "example:"
      echo "  $( basename ${0} ) 6400ff"
      echo
      return 1
    fi

    display -size 256x256 xc:"#${1}"
  }

# FUNCTIONS / dseq / GENERATE SEQUENCE OF DATES RELATIVE TO TODAY
  dseq() {
    #
    # Usage: dseq LAST
    #        dseq FIRST LAST
    #        dseq FIRST INCREMENT LAST
    #
    # Examples:
    #   $ dseq 1       # tomorrow
    #   $ dseq 0 0     # today
    #   $ dseq 7       # next 7 days
    #   $ dseq -2 0    # day before yesterday till today
    #   $ dseq 1 7 365 # tomorrow and then every week for year
    #
    if ! type gdate 1> /dev/null 2> /dev/null
    then
      echo
      echo "NOPE: install 'sysutils/coreutils' to use dseq(1)"
      echo
      echo "HINT: # pkg install -y sysutils/coreutils"
      echo
      exit 1
    fi
    seq -f "%g day" "${@}" | gdate --file - +%F
  }


