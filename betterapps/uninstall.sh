#!/bin/sh
source /koolshare/scripts/base.sh

cd /tmp
killall BetterApps >/dev/null 2>&1
killall kaiplus_bin >/dev/null 2>&1

rm -rf /koolshare/init.d/*betterapps.sh
rm -rf /koolshare/init.d/*BetterApps.sh
rm -rf /koolshare/bin/BetterApps
rm -rf /koolshare/betterapps
rm -rf /koolshare/res/icon-betterapps.png
rm -rf /koolshare/res/icon-BetterApps.png
rm -rf /koolshare/scripts/betterapps*.sh
rm -rf /koolshare/scripts/BetterApps*.sh
rm -rf /koolshare/webs/Module_betterapps.asp
rm -rf /koolshare/webs/Module_BetterApps.asp
rm -rf /koolshare/scripts/uninstall_betterapps.sh
rm -rf /koolshare/scripts/uninstall_BetterApps.sh
rm -rf /tmp/betterapps*
rm -rf /tmp/BetterApps*

dbus remove BetterApps_enable
dbus remove BetterApps_version
dbus remove betterapps_enable
dbus remove betterapps_version
dbus remove softcenter_module_betterapps_version
dbus remove softcenter_module_betterapps_install
dbus remove softcenter_module_betterapps_name
dbus remove softcenter_module_betterapps_title
dbus remove softcenter_module_betterapps_description
dbus remove softcenter_module_BetterApps_version
dbus remove softcenter_module_BetterApps_install
dbus remove softcenter_module_BetterApps_name
dbus remove softcenter_module_BetterApps_title
dbus remove softcenter_module_BetterApps_description
