#!/bin/sh
source /koolshare/scripts/base.sh

PORT=19290
PID=`pidof BetterApps`
HEALTH_URL="http://127.0.0.1:${PORT}/apps/api/v1/health"

if [ -n "$PID" ]; then
	if [ -x /koolshare/bin/BetterApps ]; then
		/koolshare/bin/BetterApps healthcheck "$HEALTH_URL" >/dev/null 2>&1
		HEALTH_OK=$?
	elif command -v curl >/dev/null 2>&1; then
		curl -fsS --max-time 3 "$HEALTH_URL" >/dev/null 2>&1
		HEALTH_OK=$?
	elif command -v wget >/dev/null 2>&1; then
		wget -q -T 3 -O /tmp/BetterApps_health.json "$HEALTH_URL" >/dev/null 2>&1
		HEALTH_OK=$?
		rm -f /tmp/BetterApps_health.json
	else
		http_response "【警告】：缺少健康检查工具（curl/wget）"
		exit 0
	fi
	if [ "$HEALTH_OK" = "0" ]; then
		http_response "进程运行正常，服务健康（PID：${PID}）"
	else
		http_response "【警告】：进程存在但健康检查失败（PID：${PID}）"
	fi
else
	http_response "【警告】：进程未运行！"
fi
