#! /bin/sh

# Copyright (c) 2018 Slawomir Wojciech Wojtczak (vermaden)
# All rights reserved.
#
# THIS SOFTWARE USES FREEBSD LICENSE (ALSO KNOWN AS 2-CLAUSE BSD LICENSE)
# https://www.freebsd.org/copyright/freebsd-license.html
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that following conditions are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS 'AS IS' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# ------------------------------
# NETWORK MANAGEMENT network.sh
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

# SETTINGS
LAN_IF=em0
LAN_RANDOM_MAC=0
WLAN_IF=wlan0
WLAN_PH=iwn0
WLAN_RANDOM_MAC=0
WWAN_IF=tun0
WWAN_PROFILE=WWAN
NAME=$( basename ${0} )
NETFS="nfs,smbfs,fusefs.sshfs"
TIMEOUT=16
DELAY=0.5
SUDO_WHICH=0
SUDO=0
DOAS_WHICH=0
DOAS=1
ROOT=0

# CHECK doas(8) WITH which(1)
if which doas 1> /dev/null 2> /dev/null
then
  DOAS_WHICH=1
else
  DOAS_WHICH=0
fi

# CHECK sudo(8) WITH which(1)
if which sudo 1> /dev/null 2> /dev/null
then
  SUDO_WHICH=1
else
  SUDO_WHICH=0
fi

# CHECK USER WITH whoami(1)
if [ "$( whoami )" = "root" ]
then
  ROOT=1
fi

# CHOOSE ONE FROM doas(8) AND sudo(8)
if [ ${DOAS_WHICH} -eq 1 -o ${SUDO_WHICH} -eq 1 ]
then
  if [   ${DOAS} -eq 0 -a ${SUDO} -eq 1 -a ${SUDO_WHICH} -eq 1 ]
  then
    CMD=sudo
  elif [ ${DOAS} -eq 1 -a ${SUDO} -eq 0 -a ${DOAS_WHICH} -eq 1 ]
  then
    CMD=doas
  elif [ ${DOAS} -eq 1 -a ${SUDO} -eq 1 -a ${DOAS_WHICH} -eq 1 ]
  then
    CMD=doas
  fi
elif [ ${ROOT} -eq 1 ]
then
  CMD=''
else
  echo "NOPE: This script needs 'doas' or 'sudo' to work properly."
  exit 1
fi

unset SUDO_WHICH
unset DOAS_WHICH
unset ROOT

# random_mac() ----------------------------------------------------------------
__random_mac() { # 1=INTERFACE
  if [ -f "${0}.oui.txt" ]
  then
    ( cat "${0}.oui.txt" | sort -R | head -1 | tr -d '\n'; env LC_ALL=C tr -c -d '0-9a-f' < /dev/random | head -c 6 ) | sed -e 's|\(..\)|\1:|g' -e 's|:$||'
  else
    MAC_OUI=$( ifconfig ${1} | awk '/hwaddr/ {print $2}' | awk -F ':' '{print $1 ":" $2 ":" $3}' )
    MAC_RAN=$( env LC_ALL=C tr -c -d '0-9a-f' < /dev/random | head -c 6 | sed -e 's|\(..\)|\1:|g' -e 's|:$||' )
    echo ${MAC_OUI}:${MAC_RAN}
  fi
}

# wlan_wait_associated() ------------------------------------------------------
__wlan_wait_associated() {
  while sleep ${DELAY}
  do
    local COUNT=0
    STATUS=$( ifconfig ${WLAN_IF} | awk '/status/ {print $2}' )
    if [ "${STATUS}" = "associated" ]
    then
      break
    fi
    COUNT=$(( ${COUNT} + 1 ))
    if [ ${COUNT} -gt ${TIMEOUT} ]
    then
      echo "NOPE: Could not associate with WLAN network."
      __network_reset
      exit 1
    fi
  done
}

# net_shares_umount() ---------------------------------------------------------
__net_shares_umount() {
  mount -t ${NETFS} -p \
    | awk '{print $2}' \
    | while read MNT
      do
        #DOAS# permit nopass :network as root cmd umount
        #SUDO# %network ALL = NOPASSWD: /sbin/umount -f *
        ${CMD} umount -f "${MNT}" &
        echo ${CMD} umount -f "${MNT}"
      done
}

# network_status() ------------------------------------------------------------
__network_status() {
  netstat -i -f inet
}

# network_reset() -------------------------------------------------------------
__network_reset() {
  __net_shares_umount
  #DOAS# permit nopass :network as root cmd killall args -9 wpa_supplicant
  #SUDO# %network ALL = NOPASSWD: /usr/bin/killall -9 wpa_supplicant
  ${CMD} killall -9 wpa_supplicant 1> /dev/null 2> /dev/null
  echo ${CMD} killall -9 wpa_supplicant
  #DOAS# permit nopass :network as root cmd killall args -9 ppp
  #SUDO# %network ALL = NOPASSWD: /usr/bin/killall -9 ppp
  ${CMD} killall -9 ppp            1> /dev/null 2> /dev/null
  echo ${CMD} killall -9 ppp
  #DOAS# permit nopass :network as root cmd killall args -9 dhclient
  #SUDO# %network ALL = NOPASSWD: /usr/bin/killall -9 dhclient
  ${CMD} killall -9 dhclient       1> /dev/null 2> /dev/null
  echo ${CMD} killall -9 dhclient
  #DOAS# permit nopass :network as root cmd ifconfig
  #SUDO# %network ALL = NOPASSWD: /sbin/ifconfig *
  ${CMD} ifconfig ${WLAN_IF} destroy 2> /dev/null
  echo ${CMD} ifconfig ${WLAN_IF} destroy
  #DOAS# permit nopass :network as root cmd ifconfig
  #SUDO# %network ALL = NOPASSWD: /sbin/ifconfig *
  ${CMD} ifconfig ${LAN_IF} down
  echo ${CMD} ifconfig ${LAN_IF} down
  #DOAS# permit nopass :network as root cmd tee args /etc/resolv.conf
  #SUDO# %network ALL = NOPASSWD: /usr/bin/tee /etc/resolv.conf
  echo | ${CMD} tee /etc/resolv.conf 1> /dev/null
  echo "echo | ${CMD} tee /etc/resolv.conf"
  #DOAS# permit nopass :network as root cmd /etc/rc.d/netif args onerestart
  #SUDO# %network ALL = NOPASSWD: /etc/rc.d/netif onerestart
  ${CMD} /etc/rc.d/netif onerestart 1> /dev/null 2> /dev/null
  echo ${CMD} /etc/rc.d/netif onerestart
}

# wwan_check() ----------------------------------------------------------------
__wwan_check() { # 1=PROFILE
  #DOAS# permit nopass :network as root cmd /bin/cat args /etc/ppp/ppp.conf
  #SUDO# %network ALL = NOPASSWD: /bin/cat /etc/ppp/ppp.conf
  if ! ${CMD} cat /etc/ppp/ppp.conf | grep -q "^${1}:$"
  then
    echo "NOPE: The '${1}' profile is absent in '/etc/ppp/ppp.conf' file."
    exit 1
  fi
}

# gateway_check() -------------------------------------------------------------
__gateway_check() {
  if ! grep -q nameserver /etc/resolv.conf
  then
    "${0}" dns gw
  fi
}

# usage() ---------------------------------------------------------------------
__usage() {
  echo "USAGE:"
  echo "  ${NAME} TYPE [OPTIONS]"
  echo
  echo "TYPES:"
  echo "  lan"
  echo "  wlan"
  echo "  wwan"
  echo "  dns"
  echo
  echo "OPTIONS:"
  echo "  start"
  echo "  start SSID|PROFILE"
  echo "  stop"
  echo "  example"
  echo
  echo "EXAMPLES:"
  echo "  ${NAME} lan start"
  echo "  ${NAME} lan restart"
  echo "  ${NAME} wlan start"
  echo "  ${NAME} wlan start HOME-NETWORK-SSID"
  echo "  ${NAME} wwan example"
  echo "  ${NAME} dns onic"
  echo "  ${NAME} dns udns"
  echo "  ${NAME} dns random"
  echo "  ${NAME} doas"
  echo "  ${NAME} sudo"
  echo
  exit 1
}

# usage_lan() -----------------------------------------------------------------
__usage_lan() {
  echo "USAGE:"
  echo "  ${NAME} lan [OPTIONS]"
  echo
  echo "EXAMPLES:"
  echo "  ${NAME} lan start"
  echo "  ${NAME} lan example"
  echo "  ${NAME} status"
  echo "  ${NAME} stop"
  echo
  echo "CONFIG:"
  echo "  /etc/rc.conf"
  echo
  echo "EXAMPLE CONFIG:"
  echo "  \$ cat /etc/rc.conf"
  echo "  ifconfig_em0=\"DHCP\""
  echo
  exit 1
}

# usage_wlan() ----------------------------------------------------------------
__usage_wlan() {
  echo "USAGE:"
  echo "  ${NAME} wlan [OPTIONS]"
  echo
  echo "EXAMPLES:"
  echo "  ${NAME} wlan start"
  echo "  ${NAME} wlan start HOME-NETWORK-SSID"
  echo "  ${NAME} wlan example"
  echo "  ${NAME} status"
  echo "  ${NAME} stop"
  echo
  echo "CONFIG:"
  echo "  /etc/wpa_supplicant.conf"
  echo
  echo "EXAMPLE CONFIG:"
  echo
  echo "\$ cat /etc/wpa_supplicant.conf"
  echo
  echo "  network={"
  echo "    ssid=\"network\""
  echo "    psk=\"PASSWORD\""
  echo "  }"
  echo
  echo "  network={"
  echo "    ssid=\"C001P\""
  echo "    scan_ssid=1"
  echo "    key_mgmt=WPA-EAP"
  echo "    identity=\"1234\""
  echo "    password=\"PASSWORD\""
  echo "    eap=PEAP"
  echo "    phase1=\"peaplabel=0\""
  echo "    phase2=\"auth=MSCHAPV2\""
  echo "  }"
  echo
  exit 1
}

# usage_wwan() ----------------------------------------------------------------
__usage_wwan() {
  echo "USAGE:"
  echo "  ${NAME} wwan [OPTIONS]"
  echo
  echo "EXAMPLES:"
  echo "  ${NAME} wwan start"
  echo "  ${NAME} wwan start profile"
  echo "  ${NAME} wwan example"
  echo "  ${NAME} status"
  echo "  ${NAME} stop"
  echo
  echo "CONFIG:"
  echo "  /etc/ppp/ppp"
  echo
  echo "EXAMPLE CONFIG:"
  echo
  echo "\$ cat /etc/ppp/ppp"
  echo
  echo "default:"
  echo "  set log Phase Chat LCP IPCP CCP tun command"
  echo
  echo "${WWAN_PROFILE}:"
  echo '  set device /dev/cuaU0'
  echo '  set speed 921600'
  echo '  set dial "ABORT BUSY ABORT NO\\sCARRIER TIMEOUT 5 \'
  echo '    \"\" AT OK-AT-OK \'
  echo '         AT+CFUN=1 OK \'
  echo '         AT+COPS=0 OK \'
  echo '         AT+CGDCONT=1,\\\"IP\\\",\\\"www.plusgsm.pl\\\" OK \'
  echo '         \dATDT\\T TIMEOUT 80 CONNECT"'
  echo '  set logout "ABORT BUSY ABORT ERROR TIMEOUT 60 \"\" +++ATH O ATH OK"'
  echo '  set phone *99\#'
  echo '  set timeout 300'
  echo '  set ifaddr 10.64.32.16/0 10.64.32.16/0 255.255.255.255 0.0.0.0'
  echo '  add default HISADDR'
  echo '  enable dns'
  echo '  disable ipv6cp'
  echo
  exit 1
}

# usage_dns() -----------------------------------------------------------------
__usage_dns() {
  echo "USAGE:"
  echo "  ${NAME} dns [OPTIONS]"
  echo
  echo "EXAMPLES:"
  echo "  ${NAME} dns onic"
  echo "  ${NAME} dns udns"
  echo "  ${NAME} dns random"
  echo
  echo "CONFIG:"
  echo "  /etc/resolv.conf"
  echo
  echo "EXAMPLE CONFIG:"
  echo "  \$ cat resolv.conf"
  echo "  nameserver 87.98.175.85"
  echo "  nameserver 193.183.98.66"
  echo
  cat << __EOF
NOLOGGING DNS SERVERS:
  OpenNIC https://servers.opennicproject.org/
    87.98.175.85
    193.183.98.66

  UncensoredDNS https://blog.uncensoreddns.org/
   91.239.100.100 (anycast)
   89.233.43.71   (unicast)

  Swiss Privacy Foundation http://privacyfoundation.ch/de/service/server.html
    77.109.138.45
    77.109.139.29

  CCC http://www.ccc.de/censorship/dns-howto
    85.214.20.141
    204.152.184.76
    194.150.168.168
    213.73.91.35

  Comodo Secure DNS https://www.comodo.com/secure-dns/
    8.26.56.26
    8.20.247.20

  DNS Watch https://dns.watch/index
    84.200.69.80
    84.200.70.40

  Fool DNS http://www.fooldns.com/fooldns-community/
    87.118.111.215
    213.187.11.62

  Free DNS http://freedns.zone/
    37.235.1.174
    37.235.1.177

__EOF
  exit 1
}



case ${1} in

  # LAN =======================================================================
  (lan) # LAN BEGIN
    case ${2} in
      (start|restart) # LAN (RE)START
        __network_reset
        if [ "${LAN_RANDOM_MAC}" = "1" ]
        then
          #DOAS# permit nopass :network as root cmd ifconfig
          #SUDO# %network ALL = NOPASSWD: /sbin/ifconfig *
          MAC=$( __random_mac )
          ${CMD} ifconfig ${LAN_IF} ether ${MAC}
          echo ${CMD} ifconfig ${LAN_IF} ether ${MAC}
          MAC=0
        fi
        #DOAS# permit nopass :network as root cmd ifconfig
        #SUDO# %network ALL = NOPASSWD: /sbin/ifconfig *
        ${CMD} ifconfig ${LAN_IF} up
        echo ${CMD} ifconfig ${LAN_IF} up
        #DOAS# permit nopass :network as root cmd dhclient
        #SUDO# %network ALL = NOPASSWD: /sbin/dhclient *
        ${CMD} dhclient ${LAN_IF} 1> /dev/null 2> /dev/null
        echo ${CMD} dhclient ${LAN_IF}

        __gateway_check

        # resolvconf -u

        ;;

      (example) # LAN USAGE
        __usage_lan
        ;;

      (*) # USAGE
        __usage
        ;;

    esac # LAN END
    ;;

  # WLAN ======================================================================
  (wlan) # WLAN BEGIN
    case ${2} in
      (start|restart) # WLAN (RE)START
        __network_reset
        #DOAS# permit nopass :network as root cmd ifconfig
        #SUDO# %network ALL = NOPASSWD: /sbin/ifconfig *
        ${CMD} ifconfig ${WLAN_IF} create wlandev ${WLAN_PH}
        echo ${CMD} ifconfig ${WLAN_IF} create wlandev ${WLAN_PH}
        if [ "${WLAN_RANDOM_MAC}" = "1" ]
        then
          #DOAS# permit nopass :network as root cmd ifconfig
          #SUDO# %network ALL = NOPASSWD: /sbin/ifconfig *
          MAC=$( __random_mac )
          ${CMD} ifconfig ${WLAN_IF} ether ${MAC}
          echo ${CMD} ifconfig ${WLAN_IF} ether ${MAC}
          MAC=0
        fi
        ${CMD} ifconfig ${WLAN_IF} up
        echo ${CMD} ifconfig ${WLAN_IF} up
        if [ ${3} ]
        then
          #DOAS# permit nopass :network as root cmd ifconfig
          #SUDO# %network ALL = NOPASSWD: /sbin/ifconfig *
          ${CMD} ifconfig ${WLAN_IF} ssid "${3}"
          echo ${CMD} ifconfig ${WLAN_IF} ssid "${3}"
        fi
        #DOAS# permit nopass :network as root cmd wpa_supplicant
        #SUDO# %network ALL = NOPASSWD: /usr/sbin/wpa_supplicant *
        ${CMD} wpa_supplicant -i ${WLAN_IF} -c /etc/wpa_supplicant.conf -s -B
        echo ${CMD} wpa_supplicant -i ${WLAN_IF} -c /etc/wpa_supplicant.conf -s -B
        __wlan_wait_associated
        #DOAS# permit nopass :network as root cmd dhclient
        #SUDO# %network ALL = NOPASSWD: /sbin/dhclient *
        ${CMD} dhclient ${WLAN_IF} 1> /dev/null 2> /dev/null
        echo ${CMD} dhclient ${WLAN_IF}

        __gateway_check

        # resolvconf -u

        #DOAS# permit nopass :network as root cmd ifconfig
        #SUDO# %network ALL = NOPASSWD: /sbin/ifconfig *
        ${CMD} ifconfig ${WLAN_IF} powersave
        echo ${CMD} ifconfig ${WLAN_IF} powersave
        ;;

      (example) # WLAN USAGE
        __usage_wlan
        ;;

      (*) # USAGE
        __usage
        ;;

    esac # WLAN END
    ;;

  # WWAN ======================================================================
  (wwan) # WWAN BEGIN
    case ${2} in
      (start|restart) # WWAN (RE)START
        if [ ${3} ]
        then
          __wwan_check "${3}"
          WWAN_PROFILE="${3}"
        else
          __wwan_check "${WWAN_PROFILE}"
        fi
        __network_reset
        #DOAS# permit nopass :network as root cmd ppp
        #SUDO# %network ALL = NOPASSWD: /usr/sbin/ppp *
        ${CMD} ppp -ddial ${WWAN_PROFILE} 1> /dev/null 2> /dev/null
        echo ${CMD} ppp -ddial ${WWAN_PROFILE}

        # resolvconf -u

        ;;

      (example) # WWAN USAGE
        __usage_wwan
        ;;

      (*) # USAGE
        __usage
        ;;

    esac
    ;;

  # DNS =======================================================================
  (dns) # DNS BEGIN
    case ${2} in
      (gw) # SET SAME AS GATEWAY
        GW=$( route -n -4 -v get default 2> /dev/null | awk 'END{print $2}' )
        #DOAS# permit nopass :network as root cmd tee args /etc/resolv.conf
        #SUDO# %network ALL = NOPASSWD: /usr/bin/tee /etc/resolv.conf
        echo | ${CMD} tee /etc/resolv.conf 1> /dev/null
        #DOAS# permit nopass :network as root cmd tee args -a /etc/resolv.conf
        #SUDO# %network ALL = NOPASSWD: /usr/bin/tee -a /etc/resolv.conf
        echo "nameserver ${GW}" | ${CMD} tee -a /etc/resolv.conf 1> /dev/null
        echo "echo 'nameserver ${GW}'  | ${CMD} tee -a /etc/resolv.conf"
        ;;

      (onic) # DNS OpenNIC
        # OpenNIC - https://servers.opennicproject.org/ - 87.98.175.85
        # OpenNIC - https://servers.opennicproject.org/ -  193.183.98.66
        #DOAS# permit nopass :network as root cmd tee args /etc/resolv.conf
        #SUDO# %network ALL = NOPASSWD: /usr/bin/tee /etc/resolv.conf
        echo | ${CMD} tee /etc/resolv.conf 1> /dev/null
        echo "echo | ${CMD} tee /etc/resolv.conf"
        #DOAS# permit nopass :network as root cmd tee args -a /etc/resolv.conf
        #SUDO# %network ALL = NOPASSWD: /usr/bin/tee -a /etc/resolv.conf
        echo 'nameserver 87.98.175.85'  | ${CMD} tee -a /etc/resolv.conf 1> /dev/null
        echo 'nameserver 193.183.98.66' | ${CMD} tee -a /etc/resolv.conf 1> /dev/null
        echo "echo 'nameserver 87.98.175.85'  | ${CMD} tee -a /etc/resolv.conf"
        echo "echo 'nameserver 193.183.98.66' | ${CMD} tee -a /etc/resolv.conf"
        ;;

      (udns) # DNS UncensoredDNS
        # UncensoredDNS - https://blog.uncensoreddns.org/ - 91.239.100.100 (anycast)
        # UncensoredDNS - https://blog.uncensoreddns.org/ - 89.233.43.71 (unicast)
        #DOAS# permit nopass :network as root cmd tee args /etc/resolv.conf
        #SUDO# %network ALL = NOPASSWD: /usr/bin/tee /etc/resolv.conf
        echo | ${CMD} tee /etc/resolv.conf 1> /dev/null
        echo "echo | ${CMD} tee /etc/resolv.conf"
        #DOAS# permit nopass :network as root cmd tee args -a /etc/resolv.conf
        #SUDO# %network ALL = NOPASSWD: /usr/bin/tee -a /etc/resolv.conf
        echo 'nameserver 91.239.100.100'  | ${CMD} tee -a /etc/resolv.conf 1> /dev/null
        echo 'nameserver 89.233.43.71'    | ${CMD} tee -a /etc/resolv.conf 1> /dev/null
        echo "echo 'nameserver 91.239.100.100'  | ${CMD} tee -a /etc/resolv.conf"
        echo "echo 'nameserver 89.233.43.71'    | ${CMD} tee -a /etc/resolv.conf"
        ;;

      (random)
        #DOAS# permit nopass :network as root cmd tee args /etc/resolv.conf
        #SUDO# %network ALL = NOPASSWD: /usr/bin/tee /etc/resolv.conf
        echo | ${CMD} tee /etc/resolv.conf 1> /dev/null
        echo "echo | ${CMD} tee /etc/resolv.conf"

        #DOAS# permit nopass :network as root cmd tee args -a /etc/resolv.conf
        #SUDO# %network ALL = NOPASSWD: /usr/bin/tee -a /etc/resolv.conf
        cat << __EOF | sort -R | head -1 | ${CMD} tee -a /etc/resolv.conf 1> /dev/null
nameserver 87.98.175.85
nameserver 193.183.98.66
nameserver 91.239.100.100
nameserver 89.233.43.71
nameserver 77.109.138.45
nameserver 77.109.139.29
nameserver 85.214.20.141
nameserver 204.152.184.76
nameserver 194.150.168.168
nameserver 213.73.91.35
nameserver 8.26.56.26
nameserver 8.20.247.20
nameserver 84.200.69.80
nameserver 84.200.70.40
nameserver 87.118.111.215
nameserver 213.187.11.62
nameserver 37.235.1.174
nameserver 37.235.1.177
__EOF
        echo "cat << __EOF | sort -R | head -1 | ${CMD} tee -a /etc/resolv.conf"
        ;;

      (example)
        __usage_dns
        ;;
    esac
    ;;



  # STOP ======================================================================
  (stop)
    __network_reset
    ;;

  # STATUS ====================================================================
  (status)
    __network_status
    ;;

  # DOAS ======================================================================
  (doas)
    echo "  # pw groupmod network -m YOURUSERNAME"
    echo "  # cat /usr/local/etc/doas.conf"
    grep -E "^[\ \n\t]+#DOAS#" "${0}" | awk '{$1=" "}1' | sort -u | sed 1d
    ;;

  # SUDO ======================================================================
  (sudo)
    echo "  # pw groupmod network -m YOURUSERNAME"
    echo "  # cat /usr/local/etc/sudoers"
    grep -E "^[\ \n\t]+#SUDO#" "${0}" | awk '{$1=" "}1' | sort -u | sed 1d
    ;;

  # USAGE =====================================================================
  (*) # USAGE
    __usage
    ;;

esac

echo '1' >> ~/scripts/stats/$( basename ${0} )
