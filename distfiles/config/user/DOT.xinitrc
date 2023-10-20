#! /bin/sh

# PATH
  export PATH=${PATH}:~/scripts:~/scripts/bin:~/.cargo/bin:~/.local/bin

# SET PROPER locale(1)
  export LC_ALL=en_US.UTF-8

# CLEAN /tmp AT STARTUP
  __openbox_clean_tmp.sh &

# DISABLE at-spi2-registryd AND at-spi-bus-launcher
  export NO_AT_BRIDGE=1

# DISABLE WIFI NETWORK POLLING (SCAN) EVERY 30 SECONDS
  export QT_BEARER_POLL_TIMEOUT=-1

# MODIFY QT FONT DPI
  export QT_FONT_DPI=75

# XDG
  export DESKTOP_SESSION=openbox
  export XDG_SESSION_DESKTOP=openbox
  export XDG_CURRENT_DESKTOP=openbox
  export XDG_SESSION_CLASS=user
  export XDG_SESSION_TYPE=x11

# XDG DIR FOR USER SPECIFIC RUNTIME FILES
  mkdir -p   ${XDG_RUNTIME_DIR} &
  chmod 700  ${XDG_RUNTIME_DIR} &
  export       XDG_RUNTIME_DIR=/tmp/vuk

# DISABLE GVFS FUSE ~/.gvfs MOUNT
  export GVFS_DISABLE_FUSE=1

# ENABLE virtualbox(1) SHARED CLIPBOARD WHEN IN VM
  if [ "$( sysctl -n kern.vm_guest )" != "none" ]
  then
    VBoxClient --clipboard 1> /dev/null 2> /dev/null &
  fi

# DISABLE virtualbox(1) LOGGING ENTIRELY
  export VBOX_LOG_DEST=nofile
  export VBOX_LOG_FLAGS=disabled
  export VBOX_LOG=-all

# QT MUST KNOW WHERE IS GTK2 CONFIG
  export GTK2_RC_FILES="${HOME}/.gtkrc-2.0"

# QT5 qt5ct
  export QT_QPA_PLATFORMTHEME=qt5ct

# GTK/QT ANTIALIASING
  export QT_XFT=1
  export GDK_USE_XFT=1

# FORCE LIBREOFFICE TO USE GTK2 THEME
  export OOO_FORCE_DESKTOP=gnome

# WM
  openbox 1> /dev/null 2> /dev/null & WM=${!}

# DAEMONS/TOOLS/TASKBARS/BACKGROUND
  xsetroot -solid gray50                                               &
  setxkbmap -option terminate:ctrl_alt_bksp,caps:none en               &
  xbindkeys                                  1> /dev/null 2> /dev/null &
  flameshot                                  1> /dev/null 2> /dev/null &
  random-wallpaper.sh ~/gfx/wallpapers       1> /dev/null 2> /dev/null &
               __openbox_restart_redshift.sh 1> /dev/null 2> /dev/null &
               __openbox_restart_plank.sh    1> /dev/null 2> /dev/null &
               __openbox_restart_compton.sh  1> /dev/null 2> /dev/null &
  ( sleep 1 && __openbox_restart_dzen2.sh )  1> /dev/null 2> /dev/null &
  ( sleep 1 && __openbox_restart_tint2.sh )  1> /dev/null 2> /dev/null &
  ( sleep 2 && xmodmap ~/.xmodmaprc )                                  &

# SILENCE parallel(1)
  ( echo 'will cite' | parallel --citation 1> /dev/null 2> /dev/null ) &

# X11 MOUSE
  xset m 2 5 &

# X11 SCREENSAVER
  xset s 0 &

# X11 BEEP DISABLE
  xset -b &

# MIXER VOLUMES
  mixer mic.volume=0.70     1> /dev/null 2> /dev/null &
  mixer rec.volume=0.70     1> /dev/null 2> /dev/null &
  mixer monitor.volume=0.70 1> /dev/null 2> /dev/null &

# WAIT FOR openbox(1) WM PID
  wait ${WM}

# LOGOUT WHEN X11 STARTED FROM PLAIN login(1) CONSOLE
  XINIT=$( ps -o pid,comm | awk '/xinit/ {print $1}' )
  SHELL=$( ps -o ppid -p ${XINIT} | grep -v PPID )
  LOGIN=$( ps -o ppid -p ${SHELL} | grep -v PPID )
  kill -9 ${XINIT} ${SHELL} ${LOGIN}

# EXIT
  exit 0
