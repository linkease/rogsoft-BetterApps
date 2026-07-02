#!/bin/sh
source /koolshare/scripts/base.sh

PORT=19290

remove_iptables_rule(){
	while iptables -t filter -D INPUT -p tcp --dport "${PORT}" -j ACCEPT >/dev/null 2>&1; do
		:
	done
}

cd /tmp || exit 1
killall BetterApps >/dev/null 2>&1
killall kaiplus_bin >/dev/null 2>&1
remove_iptables_rule

rm -f /koolshare/init.d/S99BetterApps.sh
rm -f /koolshare/init.d/N99BetterApps.sh
rm -rf /koolshare/bin/BetterApps
rm -rf /koolshare/res/icon-BetterApps.png
rm -f /koolshare/scripts/BetterApps_config.sh
rm -f /koolshare/scripts/BetterApps_status.sh
rm -rf /koolshare/webs/Module_BetterApps.asp
rm -f /koolshare/scripts/uninstall_BetterApps.sh
rm -rf /koolshare/BetterApps
rm -rf /tmp/BetterApps*

dbus remove BetterApps_enable
dbus remove BetterApps_version
dbus remove softcenter_module_BetterApps_version
dbus remove softcenter_module_BetterApps_install
dbus remove softcenter_module_BetterApps_name
dbus remove softcenter_module_BetterApps_title
dbus remove softcenter_module_BetterApps_description
