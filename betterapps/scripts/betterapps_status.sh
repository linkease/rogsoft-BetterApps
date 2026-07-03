#! /bin/sh
source /koolshare/scripts/base.sh

betterapps_status=`pidof BetterApps`
betterapps_pid=`ps | grep -w BetterApps | grep -v grep | awk '{print $1}'`
if [ -n "$betterapps_status" ];then
	http_response "进程运行正常！（PID：${betterapps_pid}）"
else
	http_response "【警告】：进程未运行！"
fi
