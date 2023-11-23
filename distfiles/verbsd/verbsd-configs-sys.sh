#! /bin/sh

# LOAD SETTINGS
if [ -f ./verbsd-settings.sh ]
then
  . ./verbsd-settings.sh
else
  echo "NOPE: the 'verbsd-settings.sh' is not available"
  exit 1
fi

echo "INFO: trying to copy system configs to target destinations"
mkdir -p \
  "${BEDIR}/usr/local/etc/devd" \
  "${BEDIR}/usr/local/etc/X11/xorg.conf.d" \
  "${BEDIR}/usr/local/etc/X11/xdm" \
    || __error "failed to create needed directories for system configs"
cp -v ./scripts/distfiles/config/boot-loader.conf                             \
                       "${BEDIR}/boot/loader.conf"                            \
                       | awk '{print $NF}'                                    || FAIL=1
cp -v ./scripts/distfiles/config/etc-rc.conf                                  \
                       "${BEDIR}/etc/rc.conf"                                 \
                       | awk '{print $NF}'                                    || FAIL=1
cp -v ./scripts/distfiles/config/etc-rc.local                                 \
                       "${BEDIR}/etc/rc.local"                                \
                       | awk '{print $NF}'                                    || FAIL=1
cp -v ./scripts/distfiles/config/etc-sysctl.conf                              \
                       "${BEDIR}/etc/sysctl.conf"                             \
                       | awk '{print $NF}'                                    || FAIL=1
cp -v ./scripts/distfiles/config/etc-devfs.rules                              \
                       "${BEDIR}/etc/devfs.rules"                             \
                       | awk '{print $NF}'                                    || FAIL=1
cp -v ./scripts/distfiles/config/etc-ttys                                     \
                       "${BEDIR}/etc-ttys"                                    \
                       | awk '{print $NF}'                                    || FAIL=1
cp -v ./scripts/distfiles/config/etc-localtime                                \
                       "${BEDIR}/etc/localtime"                               \
                       | awk '{print $NF}'                                    || FAIL=1
cp -v ./scripts/distfiles/config/usr-local-etc-doas.conf                      \
                       "${BEDIR}/usr/local/etc/doas.conf"                     \
                       | awk '{print $NF}'                                    || FAIL=1
cp -v ./scripts/distfiles/config/usr-local-etc-automount.conf                 \
                       "${BEDIR}/usr/local/etc/automount.conf"                \
                       | awk '{print $NF}'                                    || FAIL=1
cp -v ./scripts/distfiles/config/usr-local-etc-devd-audio_source.conf         \
                       "${BEDIR}/usr/local/etc/devd/audio_source.conf"        \
                       | awk '{print $NF}'                                    || FAIL=1
cp -v ./scripts/distfiles/config/usr-local-etc-sudoers                        \
                       "${BEDIR}/usr/local/etc/sudoers"                       \
                       | awk '{print $NF}'                                    || FAIL=1
cp -v ./scripts/distfiles/config/usr-local-etc-gitup.conf                     \
                       "${BEDIR}/usr/local/etc/gitup.conf"                    \
                       | awk '{print $NF}'                                    || FAIL=1
cp -v ./scripts/distfiles/config/usr-local-etc-X11-xorg.conf.d-touchpad.conf  \
                       "${BEDIR}/usr/local/etc/X11/xorg.conf.d/touchpad.conf" \
                       | awk '{print $NF}'                                    || FAIL=1
cp -v ./scripts/distfiles/config/usr-local-etc-X11-xorg.conf.d-flags.conf     \
                       "${BEDIR}/usr/local/etc/X11/xorg.conf.d/flags.conf"    \
                       | awk '{print $NF}'                                    || FAIL=1
cp -v ./scripts/distfiles/config/usr-local-etc-X11-xorg.conf.d-card.conf      \
                       "${BEDIR}/usr/local/etc/X11/xorg.conf.d/card.conf"     \
                       | awk '{print $NF}'                                    || FAIL=1
cp -v ./scripts/distfiles/config/usr-local-etc-X11-xorg.conf.d-keyboard.conf  \
                       "${BEDIR}/usr/local/etc/X11/xorg.conf.d/keyboard.conf" \
                       | awk '{print $NF}'                                    || FAIL=1
cp -v ./scripts/distfiles/config/usr-local-etc-X11-xdm-Xsetup_0               \
                       "${BEDIR}/usr/local/etc/X11/xdm/Xsetup_0"              \
                       | awk '{print $NF}'                                    || FAIL=1
cp -v ./scripts/distfiles/config/usr-local-etc-X11-xdm-Xresources             \
                       "${BEDIR}/usr/local/etc/X11/xdm/Xresources"            \
                       | awk '{print $NF}'                                    || FAIL=1
if [ "${FAIL}" = "1" ]
then
  __error "failed to copy at least one config into '${BEDIR}' BE"
fi
echo "INFO: system configs copied to target destinations"
