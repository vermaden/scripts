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
  bindkey -M vicmd '/' history-incremental-pattern-search-backward
  bindkey -M vicmd '?' history-incremental-pattern-search-forward

# ZSH HISTORY SEARCH FOR vi(1) INSERT MODE
  bindkey -M viins '^R' history-incremental-pattern-search-backward
  bindkey -M viins '^F' history-incremental-pattern-search-forward

# ZSH HISTORY MAPPINGS
  bindkey '^[[A' up-line-or-search
  bindkey '^[[B' down-line-or-search
  bindkey "^R" history-incremental-search-backward

# ZSH USE SHIFT-TAB FOR REVERSE COMPLETION
  bindkey '^[[Z' reverse-menu-complete

# ZSH LAST ARG FROM EARLIER COMMAND WITH [ALT]-[.]
  bindkey '\e.' insert-last-word

# ZSH BEGIN/END OF LINE
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
# cSRV="%F{magenta}"
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
  export PS1="$cTIM%T$cSTD $cSRV%m$cSTD $cUSR%n$cSTD $cPWD%~$cSTD $cPMT%#$cSTD "
  export PS2="$cTIM%T$cSTD $cUSR>$cSTD $cPWD"
# export RPS1=$'%{\e[0;34m%}%T%{\e[0m%}'

# COLOR MAN PAGES
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
    (*)       export LC_ALL=en_US.UTF-8 ;;
  esac

# ALIASES
  alias rehash='hash -r'
  alias make='env LANG=C LC_ALL=C make'
  alias h='history'
  alias c='clear'
  alias vim='vim -i NONE'
  alias fetch='fetch -Rr --no-verify-peer --no-verify-hostname'
  alias wget='wget -c -t 0'

# LS/GLS
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

# ADDITIONAL COMPLETIONS
  if [ -e /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]
  then
    source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  fi

# ADDITIONAL HIGHLIGHT
  if [ -e /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]
  then
    source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  fi

# SHORT (various)
  alias z=zsh
  alias b=beadm

# SHORT HISTORY h/H ALIASES
  alias h='< ~/.zhistory grep -i'
  alias H='< ~/.zhistory grep'

# SHORT GREP g/G ALIASES
  alias g='grep -i'
  alias G='grep'

# SHORT see.sh OPEN ALIASES
  alias o=see-pipe-open.sh
  alias s=see.sh
  alias see=see.sh
  alias i=info.sh

# SHORT OTHER
  alias d=caja

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

