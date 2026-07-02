#!/bin/sh
eval `dbus export BetterApps`
source /koolshare/scripts/base.sh
alias echo_date='echo $(date +%Y年%m月%d日\ %X):'

MODULE=BetterApps
BIN=/koolshare/bin/BetterApps
PID_FILE=/var/run/BetterApps.pid
PORT=19290

export SERVER_HOST=0.0.0.0
export SERVER_PORT=${PORT}
export SERVER_MODE=release
export SERVER_BASE_PATH=/apps/
export LINKEASE_EDITION=router-lite
export USER_DATA_PATH=/koolshare/BetterApps/data/user
export SYSTEM_DATA_PATH=/koolshare/BetterApps/data/system
export TEMP_PATH=/koolshare/BetterApps/data/tmp
export KAIPLUS_ENABLED=1
export KAIPLUS_BIN=/koolshare/BetterApps/kaiplus/bin/kaiplus_bin
export KAIPLUS_HOME=/koolshare/BetterApps/data/kaiplus
export KAIPLUS_STATIC_DIR=/koolshare/BetterApps/kaiplus/www
export KAIPLUS_DEFAULTS_DIR=/koolshare/BetterApps/kaiplus/defaults
export KAIPLUS_SYSTEM_ROLE=asusgo
export KAIPLUS_BASE_PATH=/apps/kaiplus/
export KAIPLUS_ADDR=127.0.0.1:19291
export KAIPLUS_PROXY_TARGET=http://127.0.0.1:19291
export KAIPLUS_WORKSPACE_TOOL_BINARY=/koolshare/BetterApps/kaiplus/helpers/kaiplus_workspace_tool
export KAIPLUS_WORKSPACE_TOOL_INSTALL_DIR=/koolshare/BetterApps/kaiplus/helpers
export REASONIX_CREDENTIALS_STORE=file

ensure_dirs(){
	mkdir -p "$USER_DATA_PATH" "$SYSTEM_DATA_PATH" "$TEMP_PATH" "$KAIPLUS_HOME"
}

start_app(){
	if ! ensure_dirs; then
		logger "[软件中心]: BetterApps 数据目录创建失败！"
		return 1
	fi
	kill_app
	if [ ! -x "$BIN" ]; then
		logger "[软件中心]: BetterApps 二进制不存在或不可执行！"
		return 1
	fi
	if ! start-stop-daemon -S -q -b -m -p "$PID_FILE" -x "$BIN"; then
		return 1
	fi
	[ ! -L "/koolshare/init.d/S99BetterApps.sh" ] && ln -sf /koolshare/scripts/BetterApps_config.sh /koolshare/init.d/S99BetterApps.sh
	[ ! -L "/koolshare/init.d/N99BetterApps.sh" ] && ln -sf /koolshare/scripts/BetterApps_config.sh /koolshare/init.d/N99BetterApps.sh
	return 0
}

kill_app(){
	killall BetterApps >/dev/null 2>&1
	killall kaiplus_bin >/dev/null 2>&1
	rm -f "$PID_FILE" >/dev/null 2>&1
}

remove_iptables_rule(){
	while iptables -t filter -D INPUT -p tcp --dport "${PORT}" -j ACCEPT >/dev/null 2>&1; do
		:
	done
}

load_iptables(){
	remove_iptables_rule
	iptables -t filter -I INPUT -p tcp --dport "${PORT}" -j ACCEPT >/dev/null 2>&1
}

del_iptables(){
	remove_iptables_rule
}

case $ACTION in
start)
	if [ "$BetterApps_enable" = "1" ]; then
		logger "[软件中心]: 启动 BetterApps 插件！"
		if start_app; then
			load_iptables
		else
			logger "[软件中心]: BetterApps 启动失败！"
		fi
	else
		logger "[软件中心]: BetterApps 插件未开启，不启动！"
	fi
	;;
start_nat)
	load_iptables
	;;
*)
	if [ "$BetterApps_enable" = "1" ]; then
		if start_app; then
			load_iptables
		else
			logger "[软件中心]: BetterApps 启动失败！"
		fi
		http_response "$1"
	else
		kill_app
		del_iptables
		http_response "$1"
	fi
	;;
esac
