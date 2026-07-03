#!/bin/sh
eval `dbus export betterapps`
source /koolshare/scripts/base.sh
alias echo_date='echo $(date +%Y年%m月%d日\ %X):'

BIN=/koolshare/bin/BetterApps
PID_FILE=/var/run/betterapps.pid
PORT=19290
APP_DIR=/koolshare/betterapps

export SERVER_HOST=0.0.0.0
export SERVER_PORT=${PORT}
export SERVER_MODE=release
export SERVER_BASE_PATH=/apps/
export LINKEASE_EDITION=router-lite
export USER_DATA_PATH=${APP_DIR}/data/user
export SYSTEM_DATA_PATH=${APP_DIR}/data/system
export TEMP_PATH=${APP_DIR}/data/tmp
export KAIPLUS_ENABLED=1
export KAIPLUS_BIN=${APP_DIR}/kaiplus/bin/kaiplus_bin
export KAIPLUS_HOME=${APP_DIR}/data/kaiplus
export KAIPLUS_STATIC_DIR=${APP_DIR}/kaiplus/www
export KAIPLUS_DEFAULTS_DIR=${APP_DIR}/kaiplus/defaults
export KAIPLUS_SYSTEM_ROLE=asusgo
export KAIPLUS_BASE_PATH=/apps/kaiplus/
export KAIPLUS_ADDR=127.0.0.1:19291
export KAIPLUS_PROXY_TARGET=http://127.0.0.1:19291
export KAIPLUS_WORKSPACE_TOOL_BINARY=${APP_DIR}/kaiplus/helpers/kaiplus_workspace_tool
export KAIPLUS_WORKSPACE_TOOL_INSTALL_DIR=${APP_DIR}/kaiplus/helpers
export REASONIX_CREDENTIALS_STORE=file

ensure_dirs(){
	mkdir -p "$USER_DATA_PATH" "$SYSTEM_DATA_PATH" "$TEMP_PATH" "$KAIPLUS_HOME"
}

start_ee(){
	ensure_dirs || return 1
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
