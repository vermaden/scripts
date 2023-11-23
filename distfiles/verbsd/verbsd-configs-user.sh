#! /bin/sh

# LOAD SETTINGS
if [ -f ./verbsd-settings.sh ]
then
  . ./verbsd-settings.sh
else
  echo "NOPE: the 'verbsd-settings.sh' is not available"
  exit 1
fi

echo "INFO: trying to copy user configs to target destinations"
mkdir -p \
  "${BEDIR}/${THEUSERDIR}/.config/caja/scripts" \
  "${BEDIR}/${THEUSERDIR}/.config/deadbeef"     \
  "${BEDIR}/${THEUSERDIR}/.config/fontconfig"   \
  "${BEDIR}/${THEUSERDIR}/.config/galculator"   \
  "${BEDIR}/${THEUSERDIR}/.config/htop"         \
  "${BEDIR}/${THEUSERDIR}/.config/leafpad"      \
  "${BEDIR}/${THEUSERDIR}/.config/mpv"          \
  "${BEDIR}/${THEUSERDIR}/.config/openbox"      \
  "${BEDIR}/${THEUSERDIR}/.config/plank"        \
  "${BEDIR}/${THEUSERDIR}/.config/qt5ct"        \
  "${BEDIR}/${THEUSERDIR}/.config/sakura"       \
  "${BEDIR}/${THEUSERDIR}/.config/sayonara"     \
  "${BEDIR}/${THEUSERDIR}/.config/skippy-xd"    \
  "${BEDIR}/${THEUSERDIR}/.config/Thunar"       \
  "${BEDIR}/${THEUSERDIR}/.config/viewnior"     \
  "${BEDIR}/${THEUSERDIR}/.config/Xdefaults"    \
    || __error "failed to create needed directories for user configs"
cp -v ./scripts/distfiles/config/user/DOT.config-caja/desktop-metadata               \
                 "${BEDIR}/${THEUSERDIR}/.config/caja/desktop-metadata"              \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.config-caja/scripts/ncdu.sh                \
                 "${BEDIR}/${THEUSERDIR}/.config/caja/scripts/ncdu.sh"               \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.config-caja/scripts/terminal.sh            \
                 "${BEDIR}/${THEUSERDIR}/.config/caja/scripts/terminal.sh"           \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.config-caja/scripts/thunar-mass-rename.sh  \
                 "${BEDIR}/${THEUSERDIR}/.config/caja/scripts/thunar-mass-rename.sh" \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.config-caja/scripts/thunar.sh              \
                 "${BEDIR}/${THEUSERDIR}/.config/caja/scripts/thunar.sh"             \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.config-deadbeef/config                     \
                 "${BEDIR}/${THEUSERDIR}/.config/deadbeef/config"                    \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.config-deadbeef/dspconfig                  \
                 "${BEDIR}/${THEUSERDIR}/.config/deadbeef/dspconfig"                 \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.config-fontconfig/fonts.conf               \
                 "${BEDIR}/${THEUSERDIR}/.config/fontconfig/fonts.conf"              \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.config-galculator/galculator.conf          \
                 "${BEDIR}/${THEUSERDIR}/.config/galculator/galculator.conf"         \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.config-htop/htoprc                         \
                 "${BEDIR}/${THEUSERDIR}/.config/htop/htoprc"                        \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.config-leafpad/leafpadrc                   \
                 "${BEDIR}/${THEUSERDIR}/.config/leafpad/leafpadrc"                  \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.config-mpv/mpv.conf                        \
                 "${BEDIR}/${THEUSERDIR}/.config/mpv/mpv.conf"                       \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.config-openbox/menu.xml                    \
                 "${BEDIR}/${THEUSERDIR}/.config/openbox/menu.xml"                   \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.config-openbox/rc.xml                      \
                 "${BEDIR}/${THEUSERDIR}/.config/openbox/rc.xml"                     \
                 | awk '{print $NF}'                                                 || FAIL=1
tar -xvf ./scripts/distfiles/config/user/DOT.config-openbox/icons.tar.gz             \
                 -C "${BEDIR}/${THEUSERDIR}/.config/openbox" 2>&1                    \
                 | grep -v '/$' | awk '{print $NF}'                                  || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.config-lxtask.conf                         \
                 "${BEDIR}/${THEUSERDIR}/.config-lxtask.conf"                        \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.config-mimeapps.list                       \
                 "${BEDIR}/${THEUSERDIR}/.config/mimeapps.list"                      \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.config-picom.conf                          \
                 "${BEDIR}/${THEUSERDIR}/.config/picom.conf"                         \
                 | awk '{print $NF}'                                                 || FAIL=1
tar -xvf ./scripts/distfiles/config/user/DOT.config-plank/dock1.tar.gz               \
                 -C "${BEDIR}/${THEUSERDIR}/.config/plank" 2>&1                      \
                 | grep -v '/$' | awk '{print $NF}'                                  || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.config-qt5ct/qt5ct.conf                    \
                 "${BEDIR}/${THEUSERDIR}/.config/qt5ct/qt5ct.conf"                   \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.config-sakura/sakura.conf                  \
                 "${BEDIR}/${THEUSERDIR}/.config/sakura/sakura.conf"                 \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.config-sayonara/player.db                  \
                 "${BEDIR}/${THEUSERDIR}/.config/sayonara/player.db"                 \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.config-skippy-xd/skippy-xd.rc              \
                 "${BEDIR}/${THEUSERDIR}/.config/skippy-xd/skippy-xd.rc"             \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.config-Thunar/renamerrc                    \
                 "${BEDIR}/${THEUSERDIR}/.config/Thunar/renamerrc"                   \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.config-Thunar/thunarrc                     \
                 "${BEDIR}/${THEUSERDIR}/.config/Thunar/thunarrc"                    \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.config-viewnior/viewnior.conf              \
                 "${BEDIR}/${THEUSERDIR}/.config/viewnior/viewnior.conf"             \
                 | awk '{print $NF}'                                                 || FAIL=1
tar -xvf ./scripts/distfiles/config/user/DOT.config-Xdefaults/themes.tar.gz          \
                 -C "${BEDIR}/${THEUSERDIR}/.config/Xdefaults" 2>&1                  \
                 | grep -v '/$' | awk '{print $NF}'                                  || FAIL=1
tar -xvf ./scripts/distfiles/config/user/DOT.config-Xdefaults/urxvt.tar.gz           \
         -C "${BEDIR}/${THEUSERDIR}/.config/Xdefaults" 2>&1                          \
                 | grep -v '/$' | awk '{print $NF}'                                  || FAIL=1
tar -xvf ./scripts/distfiles/config/user/DOT.config-geany.tar.gz                     \
                 -C "${BEDIR}/${THEUSERDIR}/.config" 2>&1                            \
                 | grep -v '/$' | awk '{print $NF}'                                  || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.config-Trolltech.conf                      \
                 "${BEDIR}/${THEUSERDIR}/.config/Trolltech.conf"                     \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.asoundrc                                   \
                 "${BEDIR}/${THEUSERDIR}/.asoundrc"                                  \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.exrc                                       \
                 "${BEDIR}/${THEUSERDIR}/.exrc"                                      \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.gtkrc-2.0                                  \
                 "${BEDIR}/${THEUSERDIR}/.gtkrc-2.0"                                 \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.hidden                                     \
                 "${BEDIR}/${THEUSERDIR}/.hidden"                                    \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.hushlogin                                  \
                 "${BEDIR}/${THEUSERDIR}/.hushlogin"                                 \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.inputrc                                    \
                 "${BEDIR}/${THEUSERDIR}/.inputrc"                                   \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.tint2rc                                    \
                 "${BEDIR}/${THEUSERDIR}/.tint2rc"                                   \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.vimrc                                      \
                 "${BEDIR}/${THEUSERDIR}/.vimrc"                                     \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.xbindkeysrc                                \
                 "${BEDIR}/${THEUSERDIR}/.xbindkeysrc"                               \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.Xdefaults                                  \
                 "${BEDIR}/${THEUSERDIR}/.Xdefaults"                                 \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.xmodmaprc                                  \
                 "${BEDIR}/${THEUSERDIR}/.xmodmaprc"                                 \
                 | awk '{print $NF}'                                                 || FAIL=1
cp -v ./scripts/distfiles/config/user/DOT.xinitrc                                    \
                 "${BEDIR}/${THEUSERDIR}/.xinitrc"                                   \
                 | awk '{print $NF}'                                                 || FAIL=1
ln -sf "${BEDIR}/${THEUSERDIR}/.xinitrc"                                             \
       "${BEDIR}/${THEUSERDIR}/.xsession"                                            \
                 | awk '{print $NF}'                                                 || FAIL=1
if [ "${FAIL}" = "1" ]
then
  __error "failed to copy at least one config into '${BEDIR}' BE"
fi
echo "INFO: user configs copied to target destinations"

echo "INFO: trying to copy user scripts to target destination"
mkdir -p "${BEDIR}/${THEUSERDIR}/scripts" \
  || __error "failed to create needed directory for user scripts"
while read SCRIPT
do
  cp -v "${SCRIPT}" "${BEDIR}/${THEUSERDIR}/scripts/" | awk '{print $NF}' || FAIL=1
done << EOF
$( find ./scripts -maxdepth 1 -name \*.sh | sort -u )
EOF
if [ "${FAIL}" = "1" ]
then
  __error "failed to copy at least one script into '${BEDIR}' BE"
fi
echo "INFO: user scripts copied to target destination"

echo "INFO: trying to copy user wallpapers to target destination"
mkdir -p "${BEDIR}/${THEUSERDIR}/gfx/wallpapers" \
  || __error "failed to create needed directory for user wallpapers"
while read WALLPAPER
do
  tar -C "${BEDIR}/${THEUSERDIR}/gfx/wallpapers" \
      -xvf "${WALLPAPER}" 2>&1 \
      | grep -v '/$' | awk '{print $NF}' || FAIL=1
done << EOF
$( find ./scripts/distfiles -maxdepth 1 -name wallpapers-\* )
EOF
if [ "${FAIL}" = "1" ]
then
  __error "failed to copy at least one wallpaper into '${BEDIR}' BE"
fi
echo "INFO: user wallpapers copied to target destination"

echo "INFO: trying to extract user applications"
tar -C "${BEDIR}" -xvf ./scripts/distfiles/apps.tar.gz 2>&1 \
  | grep -v '/$' | awk '{print $NF}' || FAIL=1
if [ "${FAIL}" = "1" ]
then
  __error "failed to extract user applications"
fi
echo "INFO: extract user fonts successfully extracted"

echo "INFO: trying to extract user fonts"
tar -C "${BEDIR}" -xvf ./scripts/distfiles/fonts.tar.gz 2>&1 \
  | grep -v '/$' | awk '{print $NF}' || FAIL=1
if [ "${FAIL}" = "1" ]
then
  __error "failed to extract user fonts"
fi
echo "INFO: extract user fonts successfully extracted"
