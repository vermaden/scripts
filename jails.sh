#! /bin/sh

# Copyright (c) 2023 Slawomir Wojciech Wojtczak (vermaden)
# All rights reserved.
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

# ------------------------------
# LIST ALL JAILS INFO ON FreeBSD
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com



# display usage information
__usage() {
  local NAME=${0##*/}
  echo "usage:"
  echo "  ${NAME}"
  echo "  ${NAME} -a"
  echo "  ${NAME} -h"
  echo "  ${NAME} --help"
  echo "  ${NAME} help"
  echo "  ${NAME} version"
  exit 1
}

case ${#} in
  (0)
    # do nothing and just display list of jails
    :
    ;;

  (1)
    # display version
    if [ "${1}" = "--version" -o \
         "${1}" =  "-version" -o \
         "${1}" =   "version" ]
    then
      echo "jails.sh"
      echo
      echo "jails 0.4 2023/09/30"
      echo
      exit 0
    fi

    # display help if needed
    if [ "${1}" = "-h"     -o \
         "${1}" = "--h"    -o \
         "${1}" = "help"  -o \
         "${1}" = "-help"  -o \
         "${1}" = "--help" -o \
         "${#}" -eq "0"    -o \
         "${#}" -eq "1" ]
    then
      __usage
    fi

    # do full listing with all interfaces and IP addresses
    if [ "${1}" = "-a" ]
    then
      FULL_LISTING=1
    fi
    ;;

  (*)
    __usage
    ;;
esac

JLS=$( jls 2> /dev/null )
IFCONFIG=$( env IFCONFIG_FORMAT=inet:cidr ifconfig -l ether 2> /dev/null )

(
  echo "JAIL JID TYPE VER DIR IFACE IP(s)"
  echo "---- --- ---- --- --- ----- -----"
  grep -h '^[^#]' \
    /etc/jail.conf \
    /etc/jail.conf.d/* 2> /dev/null \
    | grep -h -E '[[:space:]]*[[:alnum:]][[:space:]]*\{' \
    | tr -d '\ \t{' \
    | while read JAIL
      do

        CONFIG=$( grep -h '^[^#]' /etc/jail.conf /etc/jail.conf.d/* 2> /dev/null \
                    | grep -A 512 -E "[[:space:]]*${JAIL}*[[:space:]]*\{" \
                    | grep -B 512 -m 1 ".*[[:space:]]*\}[[:space:]]*$" )

        DIR=$( echo "${JLS}" | awk '{print $NF}' | grep -E "/${JAIL}$" )

        if [ "${DIR}" = "" ]
        then
          DIR=$( grep -h '^[^#]' \
                   /etc/jail.conf \
                   /etc/jail.conf.d/* 2> /dev/null \
                   | grep -A 512 -h -E '[[:alnum:]][[:space:]]\{' \
                   | grep -m 1 path \
                   | awk '{print $NF}' \
                   | tr -d ';' \
                   | sed -e "s.\${name}.${JAIL}.g" \
                         -e "s.\$name.${JAIL}.g" \
                   | tr -d '"' )
        fi

        VER=$( chroot ${DIR} freebsd-version -u 2> /dev/null \
                 | sed -e s.RELEASE.R.g \
                       -e s.CURRENT.C.g \
                       -e s.STABLE.S.g \
                       -e s.BETA.B.g )

        TYPE=$( jexec ${JAIL} sysctl -n security.jail.vnet 2> /dev/null )

        case ${TYPE} in

          (1)
            TYPE=vnet
            IFACE=$( jexec ${JAIL} env IFCONFIG_FORMAT=inet:cidr ifconfig -l ether 2> /dev/null | tr ' ' '\n' )
            case ${FULL_LISTING} in
              (1)
                IFACE=$( echo "${IFACE}" | tr '\n' '/' )
                IPS=$( jexec ${JAIL} env IFCONFIG_FORMAT=inet:cidr ifconfig 2> /dev/null \
                         | grep 'inet ' \
                         | grep -v 127.0.0.1 \
                         | awk '{print $2}' \
                         | tr '\n' '+' \
                         | sed '$s/.$//' )
                ;;

              (*)
                if [ $( echo "${IFACE}" | wc -l | tr -d ' ' ) -gt 3 ]
                then
                  IFACE=$( echo "${IFACE}" | head -3 | tr '\n' ' ' | tr ' ' '/' )
                else
                  IFACE=$( echo "${IFACE}" | tr '\n' ' ' | tr ' ' '/' )
                fi
                IFACE="${IFACE}(...)"
                IPS=$( jexec ${JAIL} env IFCONFIG_FORMAT=inet:cidr ifconfig 2> /dev/null \
                         | grep 'inet ' \
                         | grep -v 127.0.0.1 \
                         | awk '{print $2}' \
                         | head -3 \
                         | tr '\n' '+' \
                         | sed '$s/.$//' )
                ;;

            esac
            ;;

          (0)
            TYPE=std
            while read IP
            do
              while read INTERFACE
              do

                if env IFCONFIG_FORMAT=inet:cidr ifconfig ${INTERFACE} 2> /dev/null | grep -q "inet ${IP}"
                then
                  IFACE=${INTERFACE}
                  break
                fi
              done << EOF_INTERFACE
$( echo "${IFCONFIG}" | tr ' ' '\n' )
EOF_INTERFACE
            done << EOF_IP
$( echo "${IPS}" | tr '+' '\n' )
EOF_IP
            ;;

          (*)
            if echo "${CONFIG}" | grep -q 'vnet.interface'
            then
              TYPE=vnet
              IFACE=$( echo "${CONFIG}" | grep 'vnet.interface' | awk '{print $NF}' | tr -d ';"' )
            else
              TYPE=std
              IFACE=$( echo "${CONFIG}" | grep 'interface' | awk '{print $NF}' | tr -d ';' )
              IPS=$( echo "${CONFIG}" | grep '\.addr' | awk '{print $NF}' | tr -d ';' )
            fi
            ;;

        esac

        JID=$( echo "${JLS}" | grep -E "/${JAIL}$" | awk '{print $1}' )

        if ! jexec ${JAIL} echo / 1> /dev/null 2> /dev/null
        then
          JID=off
        fi

        [ "${JID}"   = "" ] && JID='-'
        [ "${TYPE}"  = "" ] && TYPE='-'
        [ "${DIR}"   = "" ] && DIR='-'
        [ "${IFACE}" = "" ] && IFACE='-'
        [ "${IPS}"   = "" ] && IPS='-'
        [ "${VER}"   = "" ] && VER='-'

        echo ${JAIL} ${JID} ${TYPE} ${VER} ${DIR} ${IFACE} ${IPS}

        unset JAIL JID TYPE VER DIR IFACE IPS

      done
) | column -t

