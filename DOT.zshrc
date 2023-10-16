# IMPORT doas(1) OR sudo(8) CONFIG
  if [ -f ~/.zshrc.DOAS.SUDO ]
  then
    source ~/.zshrc.DOAS.SUDO
  else
    echo "NOPE: File ~/.zshrc.DOAS.SUDO absent."
  fi

# BASICS
  export PATH=${PATH}:~/scripts:~/scripts/bin:~/.cargo/bin:~/.local/bin
  export EDITOR=vi
  export VISUAL=vi
  export BROWSER=firefox
  export MANWIDTH=tty
  export ENV=${HOME}/.shrc
  export TZ=Europe/Warsaw

# BASICS DESKTOP
  export DISPLAY=:0
  export MOZ_DISABLE_IMAGE_OPTIMIZE=1
  export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on'
  export NO_AT_BRIDGE=1

# ENABLE ICONS IN exa(1)
  case ${TERM} in
    (rxvt)   :                       ;;
    (xterm*) :                       ;;
    (*)      alias exa='exa --icons' ;;
  esac

# ALIASES
  alias aria2c='aria2c --file-allocation=none'
  alias bat='bat --color=always --style=plain'
  alias caja='caja --browser --no-desktop'
  alias cclive='cclive -c'
  alias cls='printf "\033[H\033[J"'
  alias cssh='cssh -o "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"'
  alias dfg='df -g'
  alias dig=drill
  alias dosa=doas
  alias duf='duf -style ascii'
  alias e=exa
  alias evince=atril
  alias ffmpeg='ffmpeg -hide_banner'
  alias gcp='gcp --sparse=always'
  alias Grep=grep
  alias grpe=grep
  alias ip='ifconfig | env GREP_COLOR=34 grep --color -C 256 -E "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+"'
  alias less='less --chop-long-lines'
  alias lp='/usr/local/bin/lp'
  alias lsof='lsof -w'
  alias lupe='lupe -noshape -mag 2 -nohud -geometry 300x200 -noreticle -noiff'
  alias midori='midori -p'
  alias more='less --chop-long-lines'
  alias mupdf='mupdf -r 120'
  alias nv='nc -v'
  alias open=xdg-open
  alias pbcopy=' xclip    -selection clipboard'
  alias pbpaste='xclip -o -selection clipboard'
  alias parallel='parallel --no-notice --progress -j 3'
  alias pstree='pstree -g 2'
  alias pv='pv -t -r -a -b -W -B 1048576'
  alias qr='qrencode -t ansiutf8'
  alias tac='tail -r'
  alias v="${CMD} vm"
  alias vm=v
  alias we="curl -4 http://wttr.in/Lodz\?Q\?n 2> /dev/null | sed '\$d' | sed '\$d'"
  alias x='xinit ~/.xinitrc -- -dpi 75 -nolisten tcp 1> /dev/null 2> /dev/null'
  alias yu-best='youtube-dl -c -i      --skip-unavailable-fragments'
  alias yu='     youtube-dl -c -i -f b --skip-unavailable-fragments'
  alias ssh='ssh -C -c aes128-ctr -o LogLevel=quiet -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
  alias sshfs='sshfs -C -o max_conns=2'
  alias scp='scp -o ControlMaster=yes \
                 -o ControlPath=/tmp/%r@%h:%p \
                 -o UserKnownHostsFile=/dev/null \
                 -o StrictHostKeyChecking=no'
  alias wget='wget -c --no-check-certificate \
                   -U "Opera/12.16 (X11; FreeBSD 4.11 amd64; U; en) Presto/3 Version/12"'
  alias feh="feh --scale-down \
                 --auto-rotate \
                 --auto-zoom \
                 --fontpath ~/.fonts \
                 --font       ubuntu/8 \
                 --menu-font  ubuntu/8 \
                 --title-font ubuntu/8"
