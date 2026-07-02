#!/bin/sh
source /koolshare/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'

MODEL=
UI_TYPE=ASUSWRT
FW_TYPE_CODE=
FW_TYPE_NAME=
DIR=$(cd "$(dirname "$0")"; pwd)
module=${DIR##*/}

get_model(){
	local ODMPID=$(nvram get odmpid)
	local PRODUCTID=$(nvram get productid)
	if [ -n "${ODMPID}" ]; then
		MODEL="${ODMPID}"
	else
		MODEL="${PRODUCTID}"
	fi
}

get_fw_type(){
	local KS_TAG=$(nvram get extendno | grep koolshare)
	if [ -d "/koolshare" ]; then
		if [ -n "${KS_TAG}" ]; then
			FW_TYPE_CODE="2"
			FW_TYPE_NAME="koolshare官改固件"
		else
			FW_TYPE_CODE="4"
			FW_TYPE_NAME="koolshare梅林改版固件"
		fi
	else
		if [ "$(uname -o | grep Merlin)" ]; then
			FW_TYPE_CODE="3"
			FW_TYPE_NAME="梅林原版固件"
		else
			FW_TYPE_CODE="1"
			FW_TYPE_NAME="华硕官方固件"
		fi
	fi
}

exit_install(){
	local state=$1
	case $state in
		1)
			echo_date "本插件适用于【koolshare 梅林改/官改 arm/hnd/axhnd/axhnd.675x】固件平台！"
			echo_date "你的固件平台不能安装！"
			rm -rf /tmp/${module}* >/dev/null 2>&1
			exit 1
			;;
		0|*)
			rm -rf /tmp/${module}* >/dev/null 2>&1
			exit 0
			;;
	esac
}

platform_test(){
	if [ -d "/koolshare" ] && [ -f "/koolshare/bin/httpdb" ] && [ -f "/usr/bin/skipd" ]; then
		echo_date "机型：${MODEL} ${FW_TYPE_NAME} 符合安装要求，开始安装插件！"
	else
		exit_install 1
	fi
}

get_ui_type(){
	[ "${MODEL}" = "RT-AC86U" ] && local ROG_RTAC86U=0
	[ "${MODEL}" = "GT-AC2900" ] && local ROG_GTAC2900=1
	[ "${MODEL}" = "GT-AC5300" ] && local ROG_GTAC5300=1
	[ "${MODEL}" = "GT-AX11000" ] && local ROG_GTAX11000=1
	[ "${MODEL}" = "GT-AXE11000" ] && local ROG_GTAXE11000=1
	[ "${MODEL}" = "GT-AX6000" ] && local ROG_GTAX6000=1
	local KS_TAG=$(nvram get extendno | grep koolshare)
	local EXT_NU=$(nvram get extendno)
	EXT_NU=$(echo "${EXT_NU%_*}" | grep -Eo "^[0-9]{1,10}$")
	local BUILDNO=$(nvram get buildno)
	[ -z "${EXT_NU}" ] && EXT_NU="0"
	if [ -n "${KS_TAG}" ] && [ "${MODEL}" = "RT-AC86U" ] && [ "${EXT_NU}" -lt "81918" ] && [ "${BUILDNO}" != "386" ]; then
		ROG_RTAC86U=1
	fi
	if [ "${MODEL}" = "GT-AC2900" ] && [ "${FW_TYPE_CODE}" = "3" -o "${FW_TYPE_CODE}" = "4" ]; then
		ROG_GTAC2900=0
	fi
	if [ "${MODEL}" = "GT-AX11000" -o "${MODEL}" = "GT-AX11000_BO4" ] && [ "${FW_TYPE_CODE}" = "3" -o "${FW_TYPE_CODE}" = "4" ]; then
		ROG_GTAX11000=0
	fi
	if [ "${MODEL}" = "GT-AXE11000" ] && [ "${FW_TYPE_CODE}" = "3" -o "${FW_TYPE_CODE}" = "4" ]; then
		ROG_GTAXE11000=0
	fi
	if [ "${ROG_GTAC5300}" = "1" -o "${ROG_RTAC86U}" = "1" -o "${ROG_GTAC2900}" = "1" -o "${ROG_GTAX11000}" = "1" -o "${ROG_GTAXE11000}" = "1" -o "${ROG_GTAX6000}" = "1" ]; then
		UI_TYPE="ROG"
	fi
	if [ "${MODEL%-*}" = "TUF" ]; then
		UI_TYPE="TUF"
	fi
}

install_ui(){
	get_ui_type
	if [ "${UI_TYPE}" = "ROG" ]; then
		echo_date "安装ROG皮肤！"
		sed -i '/asuscss/d' /koolshare/webs/Module_${module}.asp >/dev/null 2>&1
	elif [ "${UI_TYPE}" = "TUF" ]; then
		echo_date "安装TUF皮肤！"
		sed -i '/asuscss/d' /koolshare/webs/Module_${module}.asp >/dev/null 2>&1
		sed -i 's/3e030d/3e2902/g;s/91071f/92650F/g;s/680516/D0982C/g;s/cf0a2c/c58813/g;s/700618/74500b/g;s/530412/92650F/g' /koolshare/webs/Module_${module}.asp >/dev/null 2>&1
	elif [ "${UI_TYPE}" = "ASUSWRT" ]; then
		echo_date "安装ASUSWRT皮肤！"
		sed -i '/rogcss/d' /koolshare/webs/Module_${module}.asp >/dev/null 2>&1
	fi
}

install_now(){
	local TITLE="BetterApps"
	local DESCR="BetterApps for Asus/ROG router"
	local PLVER=$(cat "${DIR}/version")
	local ENABLE=$(dbus get ${module}_enable)

	if [ "${ENABLE}" = "1" -o -n "$(pidof BetterApps)" ]; then
		echo_date "安装前先关闭 ${TITLE} 插件，以保证更新成功！"
		killall BetterApps >/dev/null 2>&1
	fi

	rm -f /koolshare/init.d/S99BetterApps.sh /koolshare/init.d/N99BetterApps.sh

	echo_date "安装插件相关文件..."
	if [ ! -x "/tmp/${module}/bin/BetterApps" ]; then
		echo_date "缺少 BetterApps 二进制或文件不可执行，安装失败！"
		exit_install 1
	fi
	cp -f /tmp/${module}/bin/BetterApps /koolshare/bin/BetterApps || exit_install 1
	cp -rf /tmp/${module}/scripts/* /koolshare/scripts/ || exit_install 1
	cp -rf /tmp/${module}/webs/* /koolshare/webs/ || exit_install 1
	if [ -d "/tmp/${module}/kaiplus" ]; then
		rm -rf /koolshare/BetterApps/kaiplus
		mkdir -p /koolshare/BetterApps
		cp -rf /tmp/${module}/kaiplus /koolshare/BetterApps/ || exit_install 1
	fi
	if [ -d "/tmp/${module}/res" ]; then
		cp -rf /tmp/${module}/res/* /koolshare/res/ >/dev/null 2>&1
	fi
	cp -rf /tmp/${module}/uninstall.sh /koolshare/scripts/uninstall_${module}.sh || exit_install 1

	chmod 755 /koolshare/bin/BetterApps >/dev/null 2>&1
	chmod 755 /koolshare/scripts/${module}_*.sh >/dev/null 2>&1
	chmod 755 /koolshare/scripts/uninstall_${module}.sh >/dev/null 2>&1
	chmod 755 /koolshare/BetterApps/kaiplus/bin/kaiplus_bin >/dev/null 2>&1 || true
	chmod 755 /koolshare/BetterApps/kaiplus/helpers/kaiplus_workspace_tool >/dev/null 2>&1 || true
	find /koolshare/BetterApps/kaiplus/defaults -type f -path '*/scripts/*' -exec chmod 755 {} \; >/dev/null 2>&1 || true

	ln -sf /koolshare/scripts/${module}_config.sh /koolshare/init.d/S99${module}.sh
	ln -sf /koolshare/scripts/${module}_config.sh /koolshare/init.d/N99${module}.sh

	install_ui

	echo_date "设置插件默认参数..."
	dbus set ${module}_version="${PLVER}"
	dbus set softcenter_module_${module}_version="${PLVER}"
	dbus set softcenter_module_${module}_install="1"
	dbus set softcenter_module_${module}_name="${module}"
	dbus set softcenter_module_${module}_title="${TITLE}"
	dbus set softcenter_module_${module}_description="${DESCR}"

	if [ "${ENABLE}" = "1" ]; then
		echo_date "安装完毕，重新启用 ${TITLE} 插件！"
		sh /koolshare/scripts/${module}_config.sh start
	fi

	echo_date "${TITLE} 插件安装完毕！"
	exit_install 0
}

install(){
	get_model
	get_fw_type
	platform_test
	install_now
}

install
