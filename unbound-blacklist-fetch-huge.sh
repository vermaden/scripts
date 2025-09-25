
#! /bin/sh

# Copyright (c) 2020 Slawomir Wojciech Wojtczak (vermaden)
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
# FETCH DNS ANTISPAM FOR UNBOUND
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com



# SETTINGS
TYPE=always_nxdomain
TEMP=/tmp/unbound
ECHO=1
UNAME=$(uname)

case ${UNAME} in
  (FreeBSD)
    FILE=/var/unbound/conf.d/blacklist.conf
    FETCHCMD="fetch -q -o -"
    ;;
  (OpenBSD)
    FILE=/var/unbound/etc/blacklist.conf
    FETCHCMD="curl"
    ;;
  (*)
    FILE=/var/unbound/conf.d/blacklist.conf
    FETCHCMD="fetch -q -o - "
    ;;
esac



# CLEAN
[ "${ECHO}" != "0" ] && echo "rm: remove temp '${TEMP}' temp dir"
rm -rf   ${TEMP}



# TEMP DIR
[ "${ECHO}" != "0" ] && echo "mkdir: create '${TEMP}' temp dir"
mkdir -p ${TEMP}



# FETCH
[ "${ECHO}" != "0" ] && echo "fetch: ${TEMP}/lists-unbound"
${FETCHCMD} \
  https://raw.githubusercontent.com/oznu/dns-zone-blacklist/master/unbound/unbound-nxdomain.blacklist \
  https://raw.githubusercontent.com/tomzuu/blacklist-named/master/malwaredomainlist.conf              \
  https://raw.githubusercontent.com/tomzuu/blacklist-named/master/cedia_justdomains.conf              \
  1> ${TEMP}/lists-unbound 2> /dev/null

[ "${ECHO}" != "0" ] && echo "fetch: ${TEMP}/lists-domains"
${FETCHCMD} \
 'https://pgl.yoyo.org/adservers/serverlist.php?mimetype=plaintext&hostformat=plain'                                                                                   \
  http://blacklists.ntop.org/adblocker-hostnames.txt                                                                                                                   \
  http://thedumbterminal.co.uk/files/services/squidblockedsites/blocked.txt                                                                                            \
  https://280blocker.net/files/280blocker_domain.txt                                                                                                                   \
  https://bitbucket.org/ethanr/dns-blacklists/raw/8575c9f96e5b4a1308f2f12394abd86d0927a4a0/bad_lists/Mandiant_APT1_Report_Appendix_D.txt                               \
  https://blocklist.cyberthreatcoalition.org/vetted/domain.txt                                                                                                         \
  https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt                                                                                         \
  https://gitlab.com/ZeroDot1/CoinBlockerLists/raw/master/list_browser.txt                                                                                             \
  https://hostfiles.frogeye.fr/firstparty-trackers.txt                                                                                                                 \
  https://mirror1.malwaredomains.com/files/immortal_domains.txt                                                                                                        \
  https://mirror1.malwaredomains.com/files/justdomains                                                                                                                 \
  https://orca.pet/notonmyshift/domains.txt                                                                                                                            \
  https://paulgb.github.io/BarbBlock/blacklists/domain-list.txt                                                                                                        \
  https://raw.githubusercontent.com/Akamaru/Pi-Hole-Lists/master/jbfake.txt                                                                                            \
  https://raw.githubusercontent.com/angelics/pfbng/master/ads/ads-domain-list.txt                                                                                      \
  https://raw.githubusercontent.com/austinheap/sophos-xg-block-lists/master/coinblocker.txt                                                                            \
  https://raw.githubusercontent.com/austinheap/sophos-xg-block-lists/master/dan-pollock-someonewhocares-org.txt                                                        \
  https://raw.githubusercontent.com/austinheap/sophos-xg-block-lists/master/kadhosts.txt                                                                               \
  https://raw.githubusercontent.com/austinheap/sophos-xg-block-lists/master/malware-domain-list.txt                                                                    \
  https://raw.githubusercontent.com/austinheap/sophos-xg-block-lists/master/nocoin.txt                                                                                 \
  https://raw.githubusercontent.com/cbuijs/shallalist/master/spyware/domains                                                                                           \
  https://raw.githubusercontent.com/cbuijs/shallalist/master/tracker/domains                                                                                           \
  https://raw.githubusercontent.com/cchevy/macedonian-pi-hole-blocklist/master/hosts.txt                                                                               \
  https://raw.githubusercontent.com/Dawsey21/Lists/master/main-blacklist.txt                                                                                           \
  https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/ABP-Japanese-Paranoid-Filters.txt                           \
  https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/Adblock-Persian.txt                                         \
  https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/Adblock-YouTube-Ads.txt                                     \
  https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/Adware-Filters.txt                                          \
  https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/EasyList-Thailand.txt                                       \
  https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/FadeMind-addSpam.txt                                        \
  https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/Fanboy-Annoyances-List.txt                                  \
  https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/Filtros-Nauscopicos.txt                                     \
  https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/Hant05080-Filters.txt                                       \
  https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/Hufilter.txt                                                \
  https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/ImmortalMalwareDomains.txt                                  \
  https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/JapaneseSiteAdblockFilterver2.txt                           \
  https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/LatvianList.txt                                             \
  https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/Locky-Ransomware-C2-Domain-Blocklist.txt                    \
  https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/Malware-Domains-Just-Domains.txt                            \
  https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/PLgeneral.txt                                               \
  https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/Prebake-Obtrusive.txt                                       \
  https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/RUAdListBitBlock.txt                                        \
  https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/RUAdListCounters.txt                                        \
  https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/Schacks-Adblock-Plus-Liste.txt                              \
  https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/Steven-Blacks-Risky-Hosts.txt                               \
  https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/TakoYachty-Gift-Card-Killer.txt                             \
  https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/TeslaCrypt-Ransomware-Payment-Sites-Domain-Blocklist.txt    \
  https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/Tofu-Filter.txt                                             \
  https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/TorrentLocker-Ransomware-C2-Domain-Blocklist.txt            \
  https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/TorrentLocker-Ransomware-Payment-Sites-Domain-Blocklist.txt \
  https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/WindowsSpyBlocker7.txt                                      \
  https://raw.githubusercontent.com/deathbybandaid/piholeparser/master/Subscribable-Lists/ParsedBlacklists/ZeuS-Domain-Blocklist-Bad-Domains.txt                       \
  https://raw.githubusercontent.com/DRSDavidSoft/additional-hosts/master/domains/blacklist/unwanted-iranian.txt                                                        \
  https://raw.githubusercontent.com/greatis/Anti-WebMiner/master/blacklist.txt                                                                                         \
  https://raw.githubusercontent.com/gwillem/magento-malware-scanner/master/rules/burner-domains.txt                                                                    \
  https://raw.githubusercontent.com/hufilter/hufilter/master/hufilter-dns.txt                                                                                          \
  https://raw.githubusercontent.com/jakejarvis/ios-trackers/master/blocklist.txt                                                                                       \
  https://raw.githubusercontent.com/jdlingyu/ad-wars/master/sha_ad_hosts                                                                                               \
  https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/reject-list.txt                                                                               \
  https://raw.githubusercontent.com/MassMove/AttackVectors/master/LocalJournals/fake-local-journals-list.txt                                                           \
  https://raw.githubusercontent.com/matomo-org/referrer-spam-blacklist/master/spammers.txt                                                                             \
  https://raw.githubusercontent.com/mhhakim/pihole-blocklist/master/custom-blocklist.txt                                                                               \
  https://raw.githubusercontent.com/nextdns/cname-cloaking-blocklist/master/domains                                                                                    \
  https://raw.githubusercontent.com/ookangzheng/blahdns/master/hosts/blacklist.txt                                                                                     \
  https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/AmazonFireTV.txt                                                                                   \
  https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/android-tracking.txt                                                                               \
  https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/SessionReplay.txt                                                                                  \
  https://raw.githubusercontent.com/PoorPocketsMcNewHold/SteamScamSites/master/steamscamsitesashes                                                                     \
  https://raw.githubusercontent.com/quedlin/blacklist/master/domains                                                                                                   \
  https://raw.githubusercontent.com/soteria-nou/domain-list/master/ads.txt                                                                                             \
  https://raw.githubusercontent.com/soteria-nou/domain-list/master/affiliate.txt                                                                                       \
  https://raw.githubusercontent.com/soteria-nou/domain-list/master/fake.txt                                                                                            \
  https://raw.githubusercontent.com/Spam404/lists/master/main-blacklist.txt                                                                                            \
  https://raw.githubusercontent.com/stamparm/blackbook/master/blackbook.txt                                                                                            \
  https://raw.githubusercontent.com/stamparm/maltrail/master/trails/static/malicious/magentocore.txt                                                                   \
  https://raw.githubusercontent.com/XionKzn/PiHole-Lists/master/PiHole/Archive/Quad9.txt                                                                               \
  https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt                                                                                                 \
  https://s3.amazonaws.com/lists.disconnect.me/simple_malware.txt                                                                                                      \
  https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt                                                                                                     \
  https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt                                                                                                           \
  https://urlhaus.abuse.ch/downloads/rpz/                                                                                                                              \
  https://v.firebog.net/hosts/AdguardDNS.txt                                                                                                                           \
  https://v.firebog.net/hosts/BillStearns.txt                                                                                                                          \
  https://v.firebog.net/hosts/Easyprivacy.txt                                                                                                                          \
  https://v.firebog.net/hosts/Prigent-Phishing.txt                                                                                                                     \
  https://v.firebog.net/hosts/static/w3kbl.txt                                                                                                                         \
  https://www.botvrij.eu/data/ioclist.hostname.raw                                                                                                                     \
  https://www.stopforumspam.com/downloads/toxic_domains_whole.txt                                                                                                      \
  https://zonefiles.io/f/compromised/domains/live/                                                                                                                     \
  https://v.firebog.net/hosts/BillStearns.txt                                                                                                                          \
  1> ${TEMP}/lists-domains 2> /dev/null

cat << EOF >> ${TEMP}/lists-domains

buy.geni.us

EOF

[ "${ECHO}" != "0" ] && echo "fetch: ${TEMP}/lists-hosts"
${FETCHCMD} \
  http://sysctl.org/cameleon/hosts                                                                                                          \
  http://winhelp2002.mvps.org/hosts.txt                                                                                                     \
  https://adaway.org/hosts.txt                                                                                                              \
  https://gitlab.com/intr0/iVOID.GitLab.io/raw/master/iVOID.hosts                                                                           \
  https://gitlab.com/Kurobeats/phishing_hosts/raw/master/hosts                                                                              \
  https://hostfiles.frogeye.fr/firstparty-only-trackers-hosts.txt                                                                           \
  https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt                                                                                \
  https://hostfiles.frogeye.fr/multiparty-only-trackers-hosts.txt                                                                           \
  https://mirror1.malwaredomains.com/files/domains.hosts                                                                                    \
  https://paulgb.github.io/BarbBlock/blacklists/hosts-file.txt                                                                              \
  https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt                                                                \
  https://raw.githubusercontent.com/arcetera/Minimal-Hosts-Blocker/master/etc/MinimalHostsBlocker/minimalhosts                              \
  https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts                                                                          \
  https://raw.githubusercontent.com/bkrucarci/turk-adlist/master/hosts                                                                      \
  https://raw.githubusercontent.com/blocklistproject/Lists/master/ransomware.txt                                                            \
  https://raw.githubusercontent.com/cb-software/CB-Malicious-Domains/master/block_lists/hosts                                               \
  https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt                                                   \
  https://raw.githubusercontent.com/durablenapkin/scamblocklist/master/hosts.txt                                                            \
  https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts                                                           \
  https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts                                                             \
  https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts                                                             \
  https://raw.githubusercontent.com/hoshsadiq/adblock-nocoin-list/master/hosts.txt                                                          \
  https://raw.githubusercontent.com/ilpl/ad-hosts/master/hosts                                                                              \
  https://raw.githubusercontent.com/infinitytec/blocklists/master/scams-and-phishing.txt                                                    \
  https://raw.githubusercontent.com/jdlingyu/ad-wars/master/hosts                                                                           \
  https://raw.githubusercontent.com/joeylane/hosts/master/hosts                                                                             \
  https://raw.githubusercontent.com/kowith337/PersonalFilterListCollection/master/hosts/hosts_google_adservice_id.txt                       \
  https://raw.githubusercontent.com/Laicure/HostsY_hosts/master/shithosts                                                                   \
  https://raw.githubusercontent.com/MajkiIT/polish-ads-filter/master/polish-pihole-filters/hostfile.txt                                     \
  https://raw.githubusercontent.com/meinhimmel/hosts/master/hosts                                                                           \
  https://raw.githubusercontent.com/MetaMask/eth-phishing-detect/master/src/hosts.txt                                                       \
  https://raw.githubusercontent.com/mitchellkrogza/Badd-Boyz-Hosts/master/hosts                                                             \
  https://raw.githubusercontent.com/r-a-y/mobile-hosts/master/AdguardApps.txt                                                               \
  https://raw.githubusercontent.com/r-a-y/mobile-hosts/master/AdguardMobileAds.txt                                                          \
  https://raw.githubusercontent.com/ReddestDream/reddestdream.github.io/master/Projects/MinimalHosts/etc/MinimalHostsBlocker/minimalhosts   \
  https://raw.githubusercontent.com/ReddestDream/reddestdream.github.io/master/Projects/MinimalHostsCB/etc/MinimalHostsBlocker/minimalhosts \
  https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts                                                                          \
  https://raw.githubusercontent.com/tiuxo/hosts/master/ads                                                                                  \
  https://raw.githubusercontent.com/tyzbit/hosts/master/data/tyzbit/hosts                                                                   \
  https://raw.githubusercontent.com/vokins/yhosts/master/hosts                                                                              \
  https://raw.githubusercontent.com/w13d/adblockListABP-PiHole/master/list.txt                                                              \
  https://raw.githubusercontent.com/xorcan/hosts/master/xhosts.txt                                                                          \
  https://raw.githubusercontent.com/xxcriticxx/.pl-host-file/master/hosts.txt                                                               \
  https://raw.githubusercontent.com/yous/YousList/master/hosts.txt                                                                          \
  https://repo.andnixsh.com/adblocker/hosts                                                                                                 \
  https://someonewhocares.org/hosts/zero/hosts                                                                                              \
  https://v.firebog.net/hosts/static/HPHosts/Hostsgrm.txt                                                                                   \
  1> ${TEMP}/lists-hosts 2> /dev/null



# GENERATE
[ "${ECHO}" != "0" ] && echo "echo: add '${FILE}' header"
echo 'server:' > ${FILE}

[ "${ECHO}" != "0" ] && echo "echo: add '${FILE}' rules"
(
  # LIST UNBOUND SOURCES
  cat ${TEMP}/lists-unbound \
  | grep -v '^(.)*#' -E     \
  | grep -v '^#'            \
  | grep -v '^$'            \
  | awk -F '"' '{print $2}'

  # LIST DOMAINS SOURCES
  cat ${TEMP}/lists-domains \
  | grep -v '^(.)*#' -E     \
  | grep -v '^#'            \
  | grep -v '^$'            \
  | grep -v '^:'            \
  | grep -v '^;'            \
  | grep -v '^!'            \
  | grep -v '^@'            \
  | grep -v '^\$'           \
  | grep -v localhost       \
  | awk '{print $1}'

  # LIST HOSTS SOURCES
  cat ${TEMP}/lists-hosts   \
  | grep -v '^(.)*#' -E     \
  | grep -v '^#'            \
  | grep -v '^$'            \
  | grep -v '^!'            \
  | awk '{print $2}'

) \
  | sed -e s/$'\r'//g                           \
        -e 's|\.$||g'                           \
        -e 's|^\.||g'                           \
  | grep -v -e '127.0.0.1'                      \
            -e '0.0.0.0'                        \
            -e '255.255.255.255'                \
            -e '::'                             \
            -e 'localhost'                      \
            -e 'localhost.localdomain'          \
            -e 'ip6-localhost'                  \
            -e 'ip6-loopback'                   \
            -e 'ip6-localnet'                   \
            -e 'ip6-mcastprefix'                \
            -e 'ip6-allnodes'                   \
            -e 'ip6-allrouters'                 \
            -e 'broadcasthost'                  \
            -e 'device-metrics-us.amazon.com'   \
            -e 'device-metrics-us-2.amazon.com' \
            -e 'click.redditmail.com'           \
            -e '/'                              \
            -e '\\'                             \
            -e '('                              \
            -e ')'                              \
            -e '\['                             \
            -e '\]'                             \
            -e '^-'                             \
            -e '^_'                             \
            -e '^#'                             \
  | tr '[:upper:]' '[:lower:]'                  \
  | tr -d '\r'                                  \
  | tr -d '#'                                   \
  | sort -u                                     \
  | sed 1,2d                                    \
  | while read I
    do
      echo "local-zone: \"${I}\" ${TYPE}"
    done >> ${FILE}



# ERROR FIX: unbound-checkconf: cannot chdir(/root/bin): Permission denied
# ERROR FIX: unbound-checkconf: cannot chdir(/root):     Permission denied
cd /tmp

# CHECK CONFIG AND POTENTIALLY RESTART UNBOUND
case ${UNAME} in
  (FreeBSD)
    [ "${ECHO}" != "0" ] && echo "/etc/rc.d/local_unbound configtest"
    /etc/rc.d/local_unbound configtest
    if [ ${?} -eq 0 ]
    then
      [ "${ECHO}" != "0" ] && echo "/etc/rc.d/local_unbound restart"
      /etc/rc.d/local_unbound restart
    fi
    ;;
  (OpenBSD)
    [ "${ECHO}" != "0" ] && echo "unbound-checkconf '${FILE}'"
    unbound-checkconf "${FILE}" 1> /dev/null 2> /dev/null
    if [ ${?} -eq 0 ]
    then
      [ "${ECHO}" != "0" ] && echo "/etc/rc.d/unbound restart"
      /etc/rc.d/unbound restart
    fi
    ;;
esac



# CLEAN
[ "${ECHO}" != "0" ] && echo "rm: remove temp '${TEMP}' temp dir"
rm -r -f ${TEMP}



# UNSET
unset FILE
unset TYPE
unset TEMP
unset ECHO
unset UNAME
