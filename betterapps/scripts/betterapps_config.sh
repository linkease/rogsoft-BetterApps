#!/bin/sh
eval `dbus export betterapps`
source /koolshare/scripts/base.sh
alias echo_date='echo $(date +%Y年%m月%d日\ %X):'

BIN=/koolshare/bin/BetterApps
PID_FILE=/var/run/betterapps.pid
PORT=19290
APP_DIR=/koolshare/betterapps
APPS_PORT_FORWARD="http://127.0.0.1:${PORT}"

export SERVER_HOST=0.0.0.0
export SERVER_PORT=${PORT}
export SERVER_MODE=release
export SERVER_BASE_PATH=/apps/
export LINKEASE_EDITION=router-lite
export KAIPLUS_ENABLED=1
export KAIPLUS_BIN=${APP_DIR}/kaiplus/bin/kaiplus_bin
export KAIPLUS_STATIC_DIR=${APP_DIR}/kaiplus/www
export KAIPLUS_DEFAULTS_DIR=${APP_DIR}/kaiplus/defaults
export KAIPLUS_SYSTEM_ROLE=asusgo
export KAIPLUS_BASE_PATH=/apps/kaiplus/
export KAIPLUS_ADDR=127.0.0.1:19291
export KAIPLUS_PROXY_TARGET=http://127.0.0.1:19291
export KAIPLUS_WORKSPACE_TOOL_BINARY=${APP_DIR}/kaiplus/helpers/kaiplus_workspace_tool
export KAIPLUS_WORKSPACE_TOOL_INSTALL_DIR=${APP_DIR}/kaiplus/helpers
export REASONIX_CREDENTIALS_STORE=file

read_persisted_data_disk(){
	persisted_config=${APP_DIR}/data/bootstrap/system/data-root.json
	[ -f "$persisted_config" ] || return 0
	persisted_data_disk="$(sed -n 's/.*"selectedDisk"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$persisted_config" | head -n 1)"
	if [ -n "$persisted_data_disk" ] && [ -d "$persisted_data_disk" ]; then
		resolved_data_disk="$persisted_data_disk"
	fi
}

resolve_betterapps_data_disk(){
	resolved_data_disk=""

	if [ -n "$betterapps_data_disk" ] && [ -d "$betterapps_data_disk" ]; then
		resolved_data_disk="$betterapps_data_disk"
		return 0
	fi

	if [ -n "$betterapps_data_root_parent" ] && [ -d "$betterapps_data_root_parent" ]; then
		resolved_data_disk="$betterapps_data_root_parent"
		return 0
	fi

	case "$betterapps_data_root" in
	*/.linkease_data)
		resolved_data_disk="${betterapps_data_root%/.linkease_data}"
		if [ -n "$resolved_data_disk" ] && [ -d "$resolved_data_disk" ]; then
			return 0
		fi
		resolved_data_disk=""
		;;
	esac

	read_persisted_data_disk
	return 0
}

configure_data_paths(){
	resolve_betterapps_data_disk

	if [ -n "$resolved_data_disk" ]; then
		export BETTERAPPS_BOOTSTRAP_FALLBACK=0
		export BETTERAPPS_DATA_DISK="$resolved_data_disk"
		export BETTERAPPS_DATA_ROOT=${BETTERAPPS_DATA_DISK}/.linkease_data
		export BETTERAPPS_RECYCLE_ROOT=${BETTERAPPS_DATA_DISK}/.linkease_recycle
	else
		# Bootstrap fallback only lets the UI start before selecting a disk.
		export BETTERAPPS_BOOTSTRAP_FALLBACK=1
		export BETTERAPPS_DATA_DISK=
		export BETTERAPPS_DATA_ROOT=${APP_DIR}/data/bootstrap
		export BETTERAPPS_RECYCLE_ROOT=
	fi

	export USER_DATA_PATH=${BETTERAPPS_DATA_ROOT}/users/admin
	export SYSTEM_DATA_PATH=${BETTERAPPS_DATA_ROOT}/system
	export TEMP_PATH=${BETTERAPPS_DATA_ROOT}/tmp
	export KAIPLUS_HOME=${BETTERAPPS_DATA_ROOT}/kaiplus
}

configure_data_paths

ensure_dirs(){
	if [ "$BETTERAPPS_BOOTSTRAP_FALLBACK" = "1" ]; then
		mkdir -p "$USER_DATA_PATH" "$SYSTEM_DATA_PATH" "$TEMP_PATH" "$KAIPLUS_HOME"
	else
		mkdir -p "$USER_DATA_PATH" "$SYSTEM_DATA_PATH" "$TEMP_PATH" "$KAIPLUS_HOME" "$BETTERAPPS_RECYCLE_ROOT"
	fi
}

schedule_httpd_restart(){
	(sleep 3; service restart_httpd >/dev/null 2>&1) &
}

ensure_apps_forward(){
	current_forward="$(nvram get apps_port_forward 2>/dev/null)"
	[ "$current_forward" = "$APPS_PORT_FORWARD" ] && return 0
	nvram set apps_port_forward="$APPS_PORT_FORWARD" >/dev/null 2>&1 || return 1
	nvram commit >/dev/null 2>&1 || return 1
	logger "[软件中心]: 初始化BetterApps访问入口，稍后重启httpd！"
	schedule_httpd_restart
}

start_ee(){
	ensure_dirs || return 1
	ensure_apps_forward || return 1
	kill_ee
	start-stop-daemon -S -q -b -m -p $PID_FILE -x $BIN
	[ ! -L "/koolshare/init.d/S99betterapps.sh" ] && ln -sf /koolshare/scripts/betterapps_config.sh /koolshare/init.d/S99betterapps.sh
	[ ! -L "/koolshare/init.d/N99betterapps.sh" ] && ln -sf /koolshare/scripts/betterapps_config.sh /koolshare/init.d/N99betterapps.sh
}

kill_ee(){
	killall BetterApps >/dev/null 2>&1
	killall kaiplus_bin >/dev/null 2>&1
	rm -f $PID_FILE >/dev/null 2>&1
}

load_iptables(){
	iptables -S | grep "${PORT}" | sed 's/-A/iptables -D/g' > clean.sh && chmod 777 clean.sh && ./clean.sh && rm clean.sh >/dev/null 2>&1
	iptables -t filter -I INPUT -p tcp --dport ${PORT} -j ACCEPT >/dev/null 2>&1
}

del_iptables(){
	iptables -S | grep "${PORT}" | sed 's/-A/iptables -D/g' > clean.sh && chmod 777 clean.sh && ./clean.sh && rm clean.sh >/dev/null 2>&1
}

case $ACTION in
start)
	if [ "$betterapps_enable" == "1" ];then
		logger "[软件中心]: 启动betterapps插件！"
		kill_ee
		start_ee
		load_iptables
	else
		logger "[软件中心]: betterapps插件未开启，不启动！"
	fi
	;;
start_nat)
	load_iptables
	;;
*)
	if [ "$betterapps_enable" == "1" ];then
		kill_ee
		start_ee
		load_iptables
		http_response "$1"
	else
		kill_ee
		del_iptables
		http_response "$1"
	fi
	;;
esac
